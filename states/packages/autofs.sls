include:
  - packages.nfs

/etc/sysconfig/autofs:
  file:
    - managed
    - source: salt://assets/services/autofs
    - require:
      - pkg: autofs


autofs:
  pkg:
    - installed

  service:
    - running
    - watch:
      - file: /etc/sysconfig/autofs
    - require:
      - pkg: autofs
      - pkg: nfs-utils

