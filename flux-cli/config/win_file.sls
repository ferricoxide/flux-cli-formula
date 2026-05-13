# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as flux_cli with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}
{%- set install_dir = 'C:\\Program Files\\FluxCLI\\' %}


include:
  - {{ sls_package_install }}

Ensure Flux CLI Autocompletion in Global (default) Windows PowerShell Profile:
  file.blockreplace:
    - name: 'C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1'
    - marker_start: '# --- START FLUX CLI AUTOLOAD ---'
    - marker_end: '# --- END FLUX CLI AUTOLOAD ---'
    - content: |
        if (Test-Path "{{ install_dir }}flux-completion.ps1") {
            . "{{ install_dir }}flux-completion.ps1"
        }
    - append_if_not_found: True
    - require:
      - file: 'Ensure Global (default) Windows PowerShell Profile Exists'
      - cmd: 'Generate Flux CLI PowerShell Autocompletion'

Ensure Flux CLI Autocompletion in Global PowerShell 7 Profile:
  file.blockreplace:
    - name: 'C:\Program Files\PowerShell\7\profile.ps1'
    - marker_start: '# --- START FLUX CLI AUTOLOAD ---'
    - marker_end: '# --- END FLUX CLI AUTOLOAD ---'
    - content: |
        if (Test-Path "{{ install_dir }}flux-completion.ps1") {
            . "{{ install_dir }}flux-completion.ps1"
        }
    - append_if_not_found: True
    - onlyif:
      - cmd: 'Test-Path "C:\Program Files\PowerShell\7"'
      - shell: powershell
    - require:
      - file: 'Ensure Global PowerShell 7 Profile Exists'
      - cmd: 'Generate Flux CLI PowerShell Autocompletion'

Ensure Global (default) Windows PowerShell Profile Exists:
  file.managed:
    - name: 'C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1'
    - replace: False

Ensure Global PowerShell 7 Profile Exists:
  file.managed:
    - name: 'C:\Program Files\PowerShell\7\profile.ps1'
    - replace: False
    - onlyif:
      - cmd: 'Test-Path "C:\Program Files\PowerShell\7"'
      - shell: powershell

Generate Flux CLI PowerShell Autocompletion:
  cmd.run:
    - name: >
        & "{{ install_dir }}flux.exe" completion powershell |
        Out-File -FilePath "{{ install_dir }}flux-completion.ps1"
        -Encoding UTF8
    - shell: powershell
    - onchanges:
      - archive: 'Extract Flux CLI from Archive-File'
