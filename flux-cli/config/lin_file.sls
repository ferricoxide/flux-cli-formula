# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as flux_cli with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}
{%- set installed_pkgs = salt['pkg.list_pkgs']() %}

include:
  - {{ sls_package_install }}

Enable podman socket for all future users:
  file.managed:
    - contents: "enable podman.socket"
    - group: root
    - mode: '0644'
    - name: '/usr/lib/systemd/user-preset/80-podman.preset'
    - only_if:
      - '[[ rpm -q --quiet podman ]]'
    - user: root

{%- if 'podman' in installed_pkgs %}
Ensure Podman Socket for Kind:
  service.running:
    - name: 'podman.socket'
    - enable: True
    - comment: "Podman detected; enabling socket for Flux/Kind compatibility."
    - require:
      - file: 'Enforce flux permissions and SELinux'
    - require_in:
      - file: 'Install user-env setup for Podman socket'
{%- endif %}

{%- if 'docker-ce' in installed_pkgs or 'docker' in installed_pkgs %}
Ensure Docker Service for Flux/Kind:
  service.running:
    - name: 'docker'
    - enable: True
    - require:
      - file: 'Enforce flux permissions and SELinux'
{%- endif %}

Fix permissions on bash-completion for Flux:
  file.managed:
    - group: root
    - mode: '0644'
    - name: '/etc/bash_completion.d/flux'
    - replace: False
    - require:
      - cmd: 'Install bash-completion for Flux'
    - user: root

Install bash-completion for Flux:
  cmd.run:
    - name: '/usr/local/bin/flux completion bash > /etc/bash_completion.d/flux'
    - onchanges:
      - archive: 'Extract flux CLI Archive'
    - require:
      - file: 'Enforce flux permissions and SELinux'

Install user-env setup for Podman socket:
  file.managed:
    - contents: |
        # Use rootless socket if available
        if [[ -S "${XDG_RUNTIME_DIR}/podman/podman.sock" ]]
        then
          export DOCKER_HOST="unix://${XDG_RUNTIME_DIR}/podman/podman.sock"
        # Fall back to system socket if the user has permissions
        elif [[ -w "/run/podman/podman.sock" ]]; then
          export DOCKER_HOST="unix:///run/podman/podman.sock"
        fi
    - group: root
    - mode: '0644'
    - name: '/etc/profile.d/flux_env.sh'
    - only_if:
      - [[ -S /run/podman/podman.sock ]]
    - user: root
