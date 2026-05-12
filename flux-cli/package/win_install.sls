# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as flux_cli with context %}
{%- set target_arch = flux_cli.get('arch', 'amd64') %}
{%- set flux_archive = 'C:\\Windows\\TEMP\\flux_windows_' ~ target_arch ~ '.zip' %}
{%- set install_dir = 'C:\\Program Files\\FluxCLI\\' %}

Download flux CLI Archive-File:
  file.managed:
    - name: '{{ flux_archive }}'
    - skip_verify: True
    - source: '{{ flux_cli.pkg.download_uri }}'

Extract Flux CLI from Archive-File:
  archive.extracted:
    - enforce_toplevel: False
    - name: '{{ install_dir }}'
    - onchanges:
      - file: 'Download flux CLI Archive-File'
    - overwrite: True
    - source: '{{ flux_archive }}'

Ensure Flux CLI is in PATH:
  win_path.exists:
    - name: '{{ install_dir }}'
    - require:
      - archive: 'Extract Flux CLI from Archive-File'

Remove staged flux CLI Archive-File:
  file.absent:
    - name: '{{ flux_archive }}'
    - require:
      - archive: 'Extract Flux CLI from Archive-File'
