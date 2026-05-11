# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as flux_cli with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}

flux-cli-config-file-file-managed:
  file.managed:
    - name: {{ flux_cli.config }}
    - source: {{ files_switch(['example.tmpl'],
                              lookup='flux-cli-config-file-file-managed'
                 )
              }}
    - mode: 644
    - user: root
    - group: {{ flux_cli.rootgroup }}
    - makedirs: True
    - template: jinja
    - require:
      - sls: {{ sls_package_install }}
    - context:
        flux_cli: {{ flux_cli | json }}
