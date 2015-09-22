{% if grains['os'] == 'ScientificLinux': %}
include:
  - open-ssh
{% endif %}
