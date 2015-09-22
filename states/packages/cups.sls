cups:
  pkg:
    - installed

  service:
    - running
    - watch:
      - file: /etc/cups/cupsd.conf
      - file: /etc/cups/printers.conf
    - require:
      - pkg: cups

cups_conf:
  file.exists:
    - name: /etc/cups/cupsd.conf

printers_conf:
  file.exists:
    - name: /etc/cups/printers.conf
