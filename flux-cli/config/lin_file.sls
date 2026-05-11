# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as flux_cli with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}
{%- set installed_pkgs = salt['pkg.list_pkgs']() %}

include:
  - {{ sls_package_install }}}

{%- if 'podman' in installed_pkgs %}
Ensure Podman Socket for Kind:
  service.running:
    - name: podman.socket
    - enable: True
    - comment: "Podman detected; enabling socket for Flux/Kind compatibility."
    - require:
      - file: 'Enforce flux permissions and SELinux'
{%- endif %}

{%- if 'docker-ce' in installed_pkgs or 'docker' in installed_pkgs %}
Ensure Docker Service for Flux/Kind:
  service.running:
    - name: docker
    - enable: True
    - require:
      - file: 'Enforce flux permissions and SELinux'
{%- endif %}
