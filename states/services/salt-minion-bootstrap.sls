###################################################################
#Basically the same as salt-minion, but lacking the more advanced #
#Grain pulling logic, which breaks under salt-ssh for some reason.#
###################################################################

#FIXME: shared code really should be unified with normal salt-minion, with only the grain section different.
{% if grains['os_family'] in ['RedHat', 'Debian']: %}

salt-minion:
# There have been problems with salt in the past that have made me desire that I could push
# out updates to my minion config without updating them.  Thus, this flag was born.
{% if not pillar.get('prevent_salt_update', True): %}
  pkg:
    - installed
{% endif %} # if not prevent_salt_update

  service.running:
    - enable: True
    - watch:
      - file: /etc/salt/grains
      - file: /etc/salt/minion


/etc/salt/minion:
  file:
    - managed
    - source: salt://assets/services/minion_single_master
    - template: jinja

{% set salt_masters = pillar.get('salt_masters', ['slprototype']) %}
    - defaults:
      salt_masters:
{% for master in salt_masters %}
        - {{ master }}
{% endfor %}

#FIXME: This clearly doesn't work.  Does it read the parent grain or something?
{% if grains['host'] in salt_masters %}
    - context:
      salt_masters:
        - localhost
{% endif %}

{% if not pillar.get('prevent_salt_update', True): %}
    - require:
      - pkg: salt-minion
{% endif %} # if not prevent_salt_update


/etc/salt/grains:
  file:
    - touch

{% endif %} # os == ScientificLinux or Debian


