# this type of state is used to contain subnet specific states. (maybe routes?)
# Intended for basically hooking "special" functionality in roles that differs
# from the generic pillar accumulation/override functionality.

/etc/sysconfig/network:
  file:
    - managed
    - source: salt://assets/configurations/network
    - template: jinja
    - defaults:
{% set hostname = grains['host'].split('.')[0] %}
      hostname: {{hostname}}
      domain: dss.pha.jhu.edu


/etc/yp.conf:
  file:
    - managed
    - source: salt://assets/services/yp.conf
    - require:
      - pkg: ypbind
    - template: jinja
    - defaults:
      domain: dss.pha.jhu.edu
      server: skysrv.pha.jhu.edu

ypbind:
  pkg:
    - installed

  service:
    - running
    - watch:
      - file: /etc/yp.conf
    - require:
      - pkg: ypbind

