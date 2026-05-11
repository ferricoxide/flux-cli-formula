# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as flux_cli with context %}

Download flux CLI Archive-File:
  file.managed:
    - name: '/tmp/flux_linux_amd64.tar.gz'
    - skip_verify: True
    - source: '{{ flux_cli.pkg.download_uri }}'
