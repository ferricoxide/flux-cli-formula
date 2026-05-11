# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as flux_cli with context %}
{%- set installed_pkgs = salt['pkg.list_pkgs']() %}
{%- set flux_archive = '/tmp/flux_linux_amd64.tar.gz' %}
{%- set flux_install_loc = '/usr/local/bin' %}

Download flux CLI Archive-File:
  file.managed:
    - name: '{{ flux_archive }}'
    - skip_verify: True
    - source: '{{ flux_cli.pkg.download_uri }}'

Enforce flux permissions and SELinux:
  file.managed:
    - name: '{{ flux_install_loc }}/flux'
    - user: root
    - group: root
    - mode: '0755'
    # SELinux labels
    - selinux:
        serole: object_r
        setype: bin_t
        seuser: system_u
    - replace: False
    - require:
      - archive: 'Extract flux CLI Archive'

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

Extract flux CLI Archive:
  archive.extracted:
    - name: '{{ flux_install_loc }}'
    - source: '{{ flux_archive }}'
    - enforce_toplevel: False
    - overwrite: True
    - options: --strip-components=0
    - onchanges:
      - file: 'Download flux CLI Archive-File'

Remove staged flux CLI Archive-File:
  file.absent:
    - name: '{{ flux_archive }}'
    - require:
      - file: 'Enforce flux permissions and SELinux'
