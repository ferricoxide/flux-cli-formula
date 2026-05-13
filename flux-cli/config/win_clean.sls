# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}

Remove Flux Autoload from Global Windows PowerShell Profile:
  file.replace:
    - name: 'C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1'
    # (?ms) enables multiline matching so we can grab the whole block at once
    - pattern: '(?ms)^# --- START FLUX CLI AUTOLOAD ---.*?# --- END FLUX CLI AUTOLOAD ---$'
    - repl: ''
    - ignore_if_missing: True

Remove Flux Autoload from Global PowerShell 7 Profile:
  file.replace:
    - name: 'C:\Program Files\PowerShell\7\profile.ps1'
    - pattern: '(?ms)^# --- START FLUX CLI AUTOLOAD ---.*?# --- END FLUX CLI AUTOLOAD ---$'
    - repl: ''
    - ignore_if_missing: True
