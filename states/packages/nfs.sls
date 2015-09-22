#TODO: use different domain configurations by subnet.
#TODO: split out which mount configuration to use by some other selector. some grain maybe?

{% if grains['os_family'] in ['RedHat', 'Debian']: %}

/etc/fstab:
  file:
    - touch
# TODO: pull the source, if desired, from pillar.
#    - managed
#    - source: salt://assets/configurations/yp.conf


nfs-utils:
  pkg:
    - installed
    - require_in:
      - service: nfs

nfs:
  service:
    - running
    - enable: True
    - watch:
      - file: /etc/fstab

  require:
    - pkg: nfs-utils

{% endif %}
