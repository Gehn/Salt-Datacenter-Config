#####################################################################################
# Populates ssh authorized keys in 4 ways.
# 1. Dynamically from a subfolder in assets using list master
# 2. Dynamically from a default_keys in pillar.
# (incomplete)
# 3. Dynamically from per-machine key listings.  (in 2-3 allow inlined or file defined keys.)
# (incomplete)
# 4. Dynamically from per-user key listings. (Push according to to-be-defined matching rules to hosts.)
#    (Potentially use the logical_group descriptor inside the user.)
######################################################################################

{% if grains['os'] == 'ScientificLinux': %}
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



{% endif %} # os == SL

