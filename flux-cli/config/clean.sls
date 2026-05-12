# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_service_clean = tplroot ~ '.service.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as flux_cli with context %}

include:
{%- if grains.kernel == "Linux" %}
  - flux-cli.config.lin_clean
{%- elif grains.kernel == "Windows" %}
  - flux-cli.config.win_clean
{%- endif %}

