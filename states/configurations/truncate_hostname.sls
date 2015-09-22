/etc/sysconfig/network:
  file:
    - managed
    - source: salt://assets/configurations/network
    - template: jinja
    - defaults:
{% set hostname = grains['host'].split('.')[0] %}
      hostname: {{hostname}}

