# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as flux_cli with context %}

{%- set target_arch = flux_cli.get('arch', 'amd64') %}
{%- set flux_archive = '/tmp/flux_linux_' ~ target_arch ~ '.tar.gz' %}
{%- set flux_install_loc = '/usr/local/bin' %}

{#- Determine the download URI #}
{%- set download_uri = flux_cli.pkg.download_uri %}
{%- set api_response = {} %}

{%- if not download_uri %}
  {%- set api_url = 'https://api.github.com/repos/fluxcd/flux2/releases/latest' %}
  {%- set api_response = salt['http.query'](api_url, decode=True, decode_type='json') %}

  {%- if 'dict' in api_response and 'tag_name' in api_response['dict'] %}
    {%- set latest_tag = api_response['dict']['tag_name'] %}
    {%- set version_num = latest_tag | replace('v', '') %}
    {%- set download_uri = 'https://github.com/fluxcd/flux2/releases/download/' ~ latest_tag ~ '/flux_' ~ version_num ~ '_linux_' ~
    target_arch ~ '.tar.gz' %}
  {%- endif %}
{%- endif %}

{%- if not download_uri %}
Halt Installation Due to Missing URL:
  test.fail_without_changes:
    - name: 'Failed to construct download_uri. Please provide the URL manually in Pillar.'
    - failhard: True
{%- elif flux_cli.pkg.download_uri %}
Download flux CLI Archive-File:
  file.managed:
    - name: '{{ flux_archive }}'
    - skip_verify: True
    - source: '{{ flux_cli.pkg.download_uri }}'
    - onchanges_in:
      - archive: 'Extract flux CLI Archive'

{%- else %}
Download flux CLI Archive-File:
  cmd.run:
    - name: 'curl -sSLf -o {{ flux_archive }} {{ download_uri }}'
    - unless: 'test -s {{ flux_archive }}'
    - onchanges_in:
      - archive: 'Extract flux CLI Archive'
{%- endif %}


Enforce flux permissions and SELinux:
  file.managed:
    - name: '{{ flux_install_loc }}/flux'
    - user: root
    - group: root
    - mode: '0755'
    # SELinux labels
    - selinux:
        serole: object_r
        setype: bin_t
        seuser: system_u
    - replace: False
    - require:
      - archive: 'Extract flux CLI Archive'

Extract flux CLI Archive:
  archive.extracted:
    - name: '{{ flux_install_loc }}'
    - source: '{{ flux_archive }}'
    - enforce_toplevel: False
    - overwrite: True
    - options: --strip-components=0

Remove staged flux CLI Archive-File:
  file.absent:
    - name: '{{ flux_archive }}'
    - require:
      - file: 'Enforce flux permissions and SELinux'
