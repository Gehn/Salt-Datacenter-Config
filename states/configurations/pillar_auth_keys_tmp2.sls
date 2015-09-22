{% if grains['os'] == 'ScientificLinux': %}
{%   set list_master = salt['cp.list_master']() %}

{%   for (user, user_fields) in salt['pillar.get']('users', {}).items() %}
{%     set uid_a = loop.index0 %} # To get around variable increment scoping problems. (forced shadowing.)

{%     for (key_map) in salt['pillar.get']('users:' + user + ':authorized_keys', []) %}
{%       set uid_b = loop.index0 %}


#FIXME: don't use the UID thing.  Just shove the key here, somehow.
{{user}}_key_{{uid_a}}_{{uid_b}}:
  ssh_auth:
    - present

{%         if (key_map.__class__ == {}.__class__) and 'user' in key_map %}
{%           set key_user = key_map['user'] %}
    - user: {{key_user}}
{%         else: %}
    - user: root
{%         endif %}


# For "just raw key" entries.
{%         if not (key_map.__class__ == {}.__class__) %}
    - name: {{key_map}}
{%         endif %} # key_map not a {}

# For entries of the form key: <key>
{%         if 'key' in key_map %}
{%           set new_key = key_map['key'] %}
    - name: {{new_key}}
{%         endif %} # key in key_map

# For entries of the form source: <source path>
{%         if 'source' in key_map %}
{%           set source = key_map['source'] %}
    - source: {{source}}
{%         endif %} # source in key_map



{%     endfor %} # for key_map in users:<user>:authorized_keys
{%   endfor %} # for user, user_fields in pillar[users]





{% endif %} # os == SL

