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

{%- if 'podman' in installed_pkgs %}
Ensure Podman Socket for Kind:
  service.running:
    - name: 'podman.socket'
    - enable: True
    - comment: "Podman detected; enabling socket for Flux/Kind compatibility."
    - require:
      - file: 'Enforce flux permissions and SELinux'
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
