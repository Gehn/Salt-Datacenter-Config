
# There have been problems with salt in the past that have made me desire that I could push
# out updates to my minion config without updating them.  Thus, this flag was born.
{% if not pillar.get('prevent_salt_update', True): %}
salt-master:
  pkg:
    - installed
{% endif %}
