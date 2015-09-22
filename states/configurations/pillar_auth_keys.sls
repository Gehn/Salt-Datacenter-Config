#####################################################################################
# Populates ssh authorized keys in 4 ways.
# 1. Dynamically from a subfolder in assets using list master
# 2. Dynamically from a default_keys in pillar.
# 3. Dynamically from per-machine key listings.  (in 2-3 allow inlined or file defined keys.)
#        (Needs touchup to avoid non-destructive bugs)
# 4. Dynamically from per-user key listings. (Push according to to-be-defined matching rules to hosts.)
#        (Potentially use the logical_group descriptor inside the user.)
######################################################################################

{% if grains['os_family'] in ['RedHat', 'Debian']: %}
{%   set list_master = salt['cp.list_master']() %}


#############################################################################
# (Method #1)
# This section looks for all public keys of the form
# 'assets/configurations/default_authorized_keys/<user>/<keyfile>'
# and populates them into the <user>'s ssh auth keys file.
#############################################################################

{%   for item in list_master %}
{%     if 'assets/configurations/default_authorized_keys/' in item %} # FIXME: and '.id_rsa.pub'?
{%       set user_path = item.split('assets/configurations/default_authorized_keys/')[1] %}
{%       set user = user_path.split('/')[0] %}

{{user_path}}: # FIXME: do I need to make this some UUID thing? can just iterate if needed...
  ssh_auth:
    - present
    - user: {{user}}
    - source: salt://assets/configurations/default_authorized_keys/{{user_path}}

{%     endif %} # item in default_authorized_keys.
{%   endfor %} # item in list_master




################################################################################
# (Method #2)
# Pushes the keys specified in its global pillar authorized_keys field.
################################################################################

{%   for (key_name, key_map) in salt['pillar.get']('authorized_keys', {}).items() %}


# not appropriately detecting collisions between some keys for no good reason)
# FIXME: also make comment specifiable?
{{key_name}}:
  ssh_auth:
    - present

{%       if key_map and 'user' in key_map %}
{%         set key_user = key_map['user'] %}
    - user: {{key_user}}
{%       else: %}
    - user: root
{%       endif %}


# For "just raw key" entries.
{%       if not key_map %}
    - name: {{key_name}}

# For entries of the form key: <key>
{%       elif 'key' in key_map %}
{%         set new_key = key_map['key'] %}
    - name: {{new_key}}

# For entries of the form source: <source path>
{%       elif key_map and 'source' in key_map %}
{%         set source = key_map['source'] %}
    - source: {{source}}


{%       endif %} # if not key_map elif * in key_map

{%   endfor %} # for key_map in users:<user>:authorized_keys




################################################################################
# (Method #3)
# This section sees if the machine the state is being run on is in pillar,
# and if it is, pushes the keys specified in its machine specific pillar file.
################################################################################

{%   for (key_name, key_map) in salt['pillar.get']('machines:' + grains['host'] + ':authorized_keys', {}).items() %}


# not appropriately detecting collisions between some keys for no good reason)
# FIXME: also make comment specifiable?
{{key_name}}:
  ssh_auth:
    - present

{%       if key_map and 'user' in key_map %}
{%         set key_user = key_map['user'] %}
    - user: {{key_user}}
{%       else: %}
    - user: root
{%       endif %}


# For "just raw key" entries.
{%       if not key_map %}
    - name: {{key_name}}

# For entries of the form key: <key>
{%       elif 'key' in key_map %}
{%         set new_key = key_map['key'] %}
    - name: {{new_key}}

# For entries of the form source: <source path>
{%       elif key_map and 'source' in key_map %}
{%         set source = key_map['source'] %}
    - source: {{source}}


{%       endif %} # if not key_map elif * in key_map

{%   endfor %} # for key_map in users:<user>:authorized_keys



################################################################################
# (Method #4)
# This section examines the user listing within pillar, and pushes per-user
# keys as specified by any desired matching criterea.
################################################################################


{%   for (user, user_fields) in salt['pillar.get']('users', {}).items() %}
{%     set uid_a = loop.index0 %} # To get around variable increment scoping problems. (forced shadowing.)

############################
# PUT ADDITIONAL SELECTION CRITEREA HERE IN THE FORM IF SUCCESS CONDITION.
# HERE YOU KNOW BOTH WHAT USER YOU'RE EXAMINING (user/user_fields) AND THE MACHINE YOU'RE IN (implicit)
# YOU MUST WRAP THE WHOLE FINAL STANZA TO THE LOWER COMMENT BLOCK.

# NOTE: this example is probably overkill.  Tone this selector down later, mostly just a demo.
{%     if 'sysadmin' in salt['pillar.get']('users:' + user + ':logical_groups', []) %}
############################

{%     for (key_name, key_map) in salt['pillar.get']('users:' + user + ':authorized_keys', {}).items() %}
{%       set uid_b = loop.index0 %}


# FIXME: don't use this uid crap.  just shove the key value here. (NOTE: this is to deal with salt
# not appropriately detecting collisions between some keys for no good reason)
# FIXME: also make comment specifiable?
{{key_name}}_key_{{uid_a}}_{{uid_b}}:
  ssh_auth:
    - present

{%         if key_map and 'user' in key_map %}
{%           set key_user = key_map['user'] %}
    - user: {{key_user}}
{%         else: %}
    - user: root
{%         endif %}


# For "just raw key" entries.
{%         if not key_map %}
    - name: {{key_name}}

# For entries of the form key: <key>
{%         elif 'key' in key_map %}
{%           set new_key = key_map['key'] %}
    - name: {{new_key}}

# For entries of the form source: <source path>
{%         elif key_map and 'source' in key_map %}
{%           set source = key_map['source'] %}
    - source: {{source}}

{%         endif %} # if not key_map elif * in key_map



{%     endfor %} # for key_map in users:<user>:authorized_keys

##################
# NOTE: PUT YOUR ENDIFS FOR SELECTION STANZAS HERE.

{%     endif %}
##################


{%   endfor %} # for user, user_fields in pillar[users]





{% endif %} # os_family in RHEL,Debian

