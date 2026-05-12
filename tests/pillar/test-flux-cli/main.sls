flux-cli:
  lookup:
    pkg:
      {%- if grains.os_family == "RedHat" %}
      name: flux-cli
      download_uri: ''
      download_sig: ''
      {%- endif %}
