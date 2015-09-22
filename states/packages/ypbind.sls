#FIXME: packages.* should be the bare installs.  the services/configurations sls should
#set up the more advanced functionality.  Right now there's a strange hybrid of the two.

yp_conf:
  file.exists:
    - name: /etc/yp.conf


ypbind:
  pkg:
    - installed

  service:
    - running
    - watch:
      - file: /etc/yp.conf
    - require:
      - pkg: ypbind

