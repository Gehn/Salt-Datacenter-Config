{% if grains['os_family'] in ['RedHat']: %}

################################################################################
# (Method #4)
# This section examines the user listing within pillar, and removes per-user
# keys as specified by any desired matching criterea.
################################################################################


{%   for (key_name, key_map) in salt['pillar.get']('expired_keys', {}).items() %}
{%     set uid = loop.index0 %}


# FIXME: don't use this uid crap.  just shove the key value here. (NOTE: this is to deal with salt
# not appropriately detecting collisions between some keys for no good reason)
# FIXME: make the user specifiable under the user auth keys field?
# FIXME: also make comment specifiable?
{{key_name}}_key_{{uid}}:
  ssh_auth:
    - absent

# FIXME: do this for having multiple users.
{%       if key_map and 'user' in key_map %}
{%         set key_user = key_map['user'] %}
    - user: {{key_user}}
{%       else: %}
    - user: root
{%       endif %}


# For "just raw key" entries.
{%       if not key_map or ('key' not in key_map) %}
    - name: {{key_name}}

# For entries of the form key: <key>
{%       elif 'key' in key_map %}
{%         set new_key = key_map['key'] %}
    - name: {{new_key}}
{%       endif %} # key not in key_map elif key in key_map


{%   endfor %} # for key_map in users:<user>:authorized_keys

{% endif %} # os == SL

