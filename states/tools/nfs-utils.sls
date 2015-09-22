nfs-utils:
  pkg:
    - installed
    - require_in:
      - service: nfs
