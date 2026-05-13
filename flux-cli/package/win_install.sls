# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as flux_cli with context %}
{%- set target_arch = flux_cli.get('arch', 'amd64') %}
{%- set flux_archive = 'C:\\Windows\\TEMP\\flux_windows_' ~ target_arch ~
    '.zip' %}
{%- set install_dir = 'C:\\Program Files\\FluxCLI\\' %}

{#- Determine the download URI #}
{%- set download_uri = flux_cli.pkg.download_uri %}
{%- set api_response = {} %}

{%- if not download_uri %}
  {%- set api_url = 'https://api.github.com/repos/fluxcd/flux2/releases/latest' %}
  {%- set api_response = salt['http.query'](api_url, decode=True, decode_type='json') %}

  {%- if 'dict' in api_response and 'tag_name' in api_response['dict'] %}
    {%- set latest_tag = api_response['dict']['tag_name'] %}
    {%- set version_num = latest_tag | replace('v', '') %}
    {%- set download_uri = 'https://github.com/fluxcd/flux2/releases/download/'
        ~ latest_tag ~ '/flux_' ~ version_num ~ '_windows_' ~ target_arch ~
        '.zip' %}
  {%- endif %}
{%- endif %}


{%- if not download_uri %}
Alert-and-exit Due to Missing URL:
  test.fail_without_changes:
    - name: 'Failed to construct download_uri. Please provide the URL manually in Pillar.'
    - failhard: True
{%- elif flux_cli.pkg.download_uri %}
Download flux CLI Archive-File:
  file.managed:
    - name: '{{ flux_archive }}'
    - onchanges_in:
      - archive: 'Extract flux CLI Archive'
    - skip_verify: True
    - source: '{{ flux_cli.pkg.download_uri }}'
{%- else %}
Announce Fall-back:
  test.show_notification:
    - text: |
        ------------------------------------------------------------------------
        No URL specified in Pillar. Attempting to download release-archive from:

          {{ download_uri }}

        ------------------------------------------------------------------------

Download flux CLI Archive-File:
  cmd.run:
    - name: 'curl -sSLf -o {{ flux_archive }} {{ download_uri }}'
    - onchanges_in:
      - archive: 'Extract flux CLI Archive'
    - require:
      - test: 'Announce Fall-back'
    - unless: 'test -s {{ flux_archive }}'
{%- endif %}

Extract flux CLI Archive:
  archive.extracted:
    - enforce_toplevel: False
    - name: '{{ install_dir }}'
    - overwrite: True
    - source: '{{ flux_archive }}'

Ensure Flux CLI is in PATH:
  win_path.exists:
    - name: '{{ install_dir }}'
    - require:
      - archive: 'Extract flux CLI Archive'

Remove staged flux CLI Archive-File:
  file.absent:
    - name: '{{ flux_archive }}'
    - require:
      - archive: 'Extract flux CLI Archive'
