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
    - require_in:
      - file: 'Install user-env setup for Podman socket'
{%- endif %}

Ensure systemd user delegation for Kind:
  file.managed:
    - contents: |
        [Service]
        Delegate=yes
    - group: root
    - makedirs: True
    - mode: '0644'
    - name: '/etc/systemd/system/user@.service.d/delegate.conf'
    - only_if:
      - '[[ -f /usr/local/bin/kind || -f /usr/bin/kind ]]'
    - user: root

Ensure bash-completion package is present:
  pkg.installed:
    - name: bash-completion
    - require:
      - file: 'Enforce flux permissions and SELinux'

Ensure the directory exists for the global link:
  file.directory:
    - group: root
    - makedirs: True
    - mode: '0755'
    - name: '/usr/lib/systemd/user/sockets.target.wants'
    - user: root

Fix permissions on bash-completion for Flux:
  file.managed:
    - group: root
    - mode: '0644'
    - name: '/etc/bash_completion.d/flux'
    - replace: False
    - require:
      - cmd: 'Install bash-completion for Flux'
    - user: root

Force podman socket globally:
  file.symlink:
    - name: '/usr/lib/systemd/user/sockets.target.wants/podman.socket'
    - target: '/usr/lib/systemd/user/podman.socket'
    - force: True
    - only_if:
      - '[[ rpm -q --quiet podman ]]'
    - require:
      - file: 'Ensure the directory exists for the global link'

Install bash-completion for Flux:
  cmd.run:
    - name: '/usr/local/bin/flux completion bash > /etc/bash_completion.d/flux'
    - onchanges:
      - archive: 'Extract flux CLI Archive'
    - require:
      - file: 'Ensure bash-completion package is present'

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

Reload systemd for delegation:
  module.run:
    - service.systemctl_reload: {}
    - onchanges:
        - file: Ensure systemd user delegation for Kind
