{% if grains['os_family'] in ['RedHat', 'Debian']: %}

include:
  - tools.openssh

sshd:
  service.running:
    - enable: True
    - require:
      - pkg: openssh

{% endif %}
