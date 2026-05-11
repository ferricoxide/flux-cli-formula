# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as flux_cli with context %}

flux-cli-service-clean-service-dead:
  service.dead:
    - name: {{ flux_cli.service.name }}
    - enable: False
