{% if grains['os_family'] in ['RedHat']: %}

/etc/ld.so.conf:
  file.append:
    - text: /usr/local/lib

{% endif %}
