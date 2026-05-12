# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as flux_cli with context %}

include:
{%- if grains.kernel == "Linux" %}
  - flux-cli.package.lin_install
{%- elif grains.kernel == "Windows" %}
  - flux-cli.package.win_install
{%- endif %}

