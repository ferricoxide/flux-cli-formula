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

Ensure Default User kubeconfig directory exists:
  file.directory:
    - makedirs: True
    - name: 'C:\Users\Default\.kube'
    - require:
      - sls: {{ sls_package_install }}

Ensure Flux CLI Autocompletion in Global (default) Windows PowerShell Profile:
  file.blockreplace:
    - append_if_not_found: True
    - content: |
        if (Test-Path "{{ install_dir }}flux-completion.ps1") {
            . "{{ install_dir }}flux-completion.ps1"
        }
        if (Test-Path "{{ install_dir }}flux-env.ps1") {
            . "{{ install_dir }}flux-env.ps1"
        }
    - marker_end: '# --- END FLUX CLI AUTOLOAD ---'
    - marker_start: '# --- START FLUX CLI AUTOLOAD ---'
    - name: 'C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1'
    - require:
      - file: 'Ensure Global (default) Windows PowerShell Profile Exists'
      - cmd: 'Generate Flux CLI PowerShell Autocompletion'
      - file: 'Install user-env setup for Windows container runtimes'

Ensure Flux CLI Autocompletion in Global PowerShell 7 Profile:
  file.blockreplace:
    - append_if_not_found: True
    - content: |
        if (Test-Path "{{ install_dir }}flux-completion.ps1") {
            . "{{ install_dir }}flux-completion.ps1"
        }
        if (Test-Path "{{ install_dir }}flux-env.ps1") {
            . "{{ install_dir }}flux-env.ps1"
        }
    - marker_end: '# --- END FLUX CLI AUTOLOAD ---'
    - marker_start: '# --- START FLUX CLI AUTOLOAD ---'
    - name: 'C:\Program Files\PowerShell\7\profile.ps1'
    - onlyif:
      - 'Test-Path "C:\Program Files\PowerShell\7"'
      - shell: powershell
    - require:
      - file: 'Ensure Global PowerShell 7 Profile Exists'
      - cmd: 'Generate Flux CLI PowerShell Autocompletion'
      - file: 'Install user-env setup for Windows container runtimes'

Ensure Global (default) Windows PowerShell Profile Exists:
  file.managed:
    - name: 'C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1'
    - replace: False

Ensure Global PowerShell 7 Profile Exists:
  file.managed:
    - name: 'C:\Program Files\PowerShell\7\profile.ps1'
    - onlyif:
      - 'Test-Path "C:\Program Files\PowerShell\7"'
      - shell: powershell
    - replace: False

Generate Flux CLI PowerShell Autocompletion:
  cmd.run:
    - name: >
        & "{{ install_dir }}flux.exe" completion powershell |
        Out-File -FilePath "{{ install_dir }}flux-completion.ps1"
        -Encoding UTF8
    - onchanges:
      - archive: 'Extract flux CLI Archive'
    - shell: powershell

Install user-env setup for Windows container runtimes:
  file.managed:
    - name: '{{ install_dir }}flux-env.ps1'
    - contents: |
        # Ensure Flux and Kind can locate the correct container socket on Windows
        if (Get-Command podman -ErrorAction SilentlyContinue) {
            $env:DOCKER_HOST = "npipe:////./pipe/podman-machine-default"
        } elseif (Get-Command docker -ErrorAction SilentlyContinue) {
            $env:DOCKER_HOST = "npipe:////./pipe/docker_engine"
        }
    - require:
      - sls: {{ sls_package_install }}
