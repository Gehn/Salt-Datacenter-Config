
salt-minion:
# There have been problems with salt in the past that have made me desire that I could push
# out updates to my minion config without updating them.  Thus, this flag was born.
{% if not pillar.get('prevent_salt_update', True): %}
  pkg:
    - installed
{% endif %}

#FIXME: move the OS selector into a more fine grained fasion.
{% if grains['os_family'] == 'RedHat': %}

  service.running:
    - enable: True
    - watch:
      - file: /etc/salt/grains
      - file: /etc/salt/minion


########################################################################
# Prepare the minion file; involving populating the master from pillar.#
########################################################################

/etc/salt/minion:
  file:
    - managed
    - source: salt://assets/services/minion_single_master
    - template: jinja
{% if not pillar.get('prevent_salt_update', True): %}
    - require:
      - pkg: salt-minion
{% endif %}

# Not neccessary, unless you're working in an entirely broke ass
# DNS setup like we're in now with no meaningful consistency, in which
# case it guarantees the master will always be able to administer itself.
# A proper DNS deployment should allow all this to disappear, except for
# populating the master through pillar, which may just actually be useful.

{% set salt_masters = pillar.get('salt_masters', ['slprototype']) %}
    - defaults:
      salt_masters:
{% for master in salt_masters %}
        - {{ master }}
{% endfor %}

# FIXME: this is a bit broken, sometimes (salt-ssh)
{% if grains['host'] in salt_masters %}
    - context:
      salt_masters:
        - localhost
{% endif %}



##########################################################################
# Bootstrap custom grains.  (this entire section is highly questionable.)#
##########################################################################


# FIXME: examine the difference between source and sources.  potentially do some sort of fallback strategy?
# FIXME: Maybe do something more generic than assuming a salt://grains/ base path?  it's a bit clunky anyway.
# FIXME: either wipe the file before appending, or in any case, do something sane that doesn't accidentally result in duplicate entries. (blockreplace would work fine.)

# NOTE: this could be done (potentially more correctly) using pillar.
# NOTE: even so, allow this to be a proof of concept for automatically deploying grains.
# NOTE: this is only "tolerable" to me as a method for bootstrapping "generic but static" grains at kickstart,
# NOTE: it should probably not be used for anything dynamic at all, and even for these generic grains, its a stretch.




# Looks for <hostname>.grains and <role>.grains files inside file_roots on the master.
# If such grain files exist, sync the shit out of them.

{% set grain_files = [] %}
{% set valid_files = salt['cp.list_master']() %}

# Do hostname association/existence checking.
{% if 'grains/' + grains['host'] + '.grains' in salt['cp.list_master']() %}
{%   do grain_files.append('grains/' + grains['host'] + '.grains') %}
{% endif %}

# Do role association/existence checking.
{% if 'roles' in grains: %}
{%   for my_role in grains['roles']: %}
{%     if 'grains/' + my_role + '.grains' in valid_files: %}
{%       do grain_files.append('grains/' + my_role + '.grains') %}
{%     endif %}
{%   endfor %}
{% endif %}

# FIXME: do this role matching from pillar too.

/etc/salt/grains:
  file:
{% if grain_files != []: %}
    - append
    - sources:
{%   for grain_file in grain_files: %}
      - salt://{{ grain_file }}
{%   endfor %}
{%   if not pillar.get('prevent_salt_update', True): %}
    - require:
      - pkg: salt-minion
{%   endif %}
{% else: %}
    - touch
{% endif %}


# This endif is for the if grains == sl
{% endif %}
