{% if grains['os_family'] in ['Redhat', 'Debian']: %}

# FIXME: make up your mind if you want packages in general going in tools rather than 
# the services that run them.
ntp:
  pkg:
    - installed

ntpd:
  service.running:
    - enable: True
    - require:
      - pkg: ntp

{% endif %}
