{% if grains['os_family'] in ['RedHat']: %}

/etc/cron.daily/0logwatch:
  file.absent

{% endif %}
