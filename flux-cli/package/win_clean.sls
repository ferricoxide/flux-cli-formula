# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_clean = tplroot ~ '.config.clean' %}
{%- set install_dir = 'C:\\Program Files\\FluxCLI\\' %}

include:
  - {{ sls_config_clean }}

Ensure Flux CLI is removed from PATH:
  win_path.absent:
    - name: '{{ install_dir }}'

Remove Flux CLI installation directory:
  file.absent:
    - name: '{{ install_dir }}'
    - require:
      - win_path: 'Ensure Flux CLI is removed from PATH'
