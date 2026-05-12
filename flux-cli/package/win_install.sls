# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as flux_cli with context %}
{%- set target_arch = flux_cli.get('arch', 'amd64') %}
{%- set flux_archive = 'C:\\Windows\\TEMP\\flux_windows_' ~ target_arch ~ '.zip' %}
{%- set install_dir = 'C:\\Program Files\\FluxCLI\\' ~ selected_edition %}

Download flux CLI Archive-File:
  file.managed:
    - name: '{{ flux_archive }}'
    - skip_verify: True
    - source: '{{ flux_cli.pkg.download_uri }}'
