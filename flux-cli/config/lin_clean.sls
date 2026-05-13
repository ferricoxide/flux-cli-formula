# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_clean = tplroot ~ '.package.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as flux_cli with context %}

include:
  - {{ sls_package_clean }}

Remove bash-completion file for Flux:
  file.absent:
    - name: '/etc/bash_completion.d/flux'

Remove shell-ENVs for Flux:
  file.absent:
    - name: '/etc/profile.d/flux_env.sh'
