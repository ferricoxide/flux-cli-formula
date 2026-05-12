# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_clean = tplroot ~ '.config.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as flux_cli with context %}

include:
  - {{ sls_config_clean }}

include:
{%- if grains.kernel == "Linux" %}
  - flux-cli.package.lin_clean
{%- elif grains.kernel == "Windows" %}
  - flux-cli.package.win_clean
{%- endif %}

