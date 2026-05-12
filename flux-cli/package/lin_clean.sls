# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_clean = tplroot ~ '.config.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as flux_cli with context %}
{%- set flux_archive = '/tmp/flux_linux_amd64.tar.gz' %}
{%- set flux_install_loc = '/usr/local/bin' %}

include:
  - {{ sls_config_clean }}

Remove flux binary:
  file.absent:
    - name: '{{ flux_install_loc }}/flux'

Remove staged flux CLI Archive-File:
  file.absent:
    - name: '{{ flux_archive }}'
