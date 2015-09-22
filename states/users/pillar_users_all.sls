#FIXME: flesh this out with additional user command as needed (requisite groups etc.).
#TODO: 2/24/2014 finish this + test.
#I think I'm deprecating this?

{% for user in pillar['users'] %}

{%   if 'users/' + user_name in pillar: %}
{%     set user_pillar = pillar['users/' + user] %}

{{ user }}:
  group.present:
    - gid: {{ user_pillar['gid'] }}
  user.present:
    - home: {{ user_pillar['home'] }}
    - shell: {{ user_pillar['shell'] }}
    - uid: {{ user_pillar['uid'] }}
    - gid: {{ user_pillar['gid'] }}

{%     if 'password' in user_pillar %}
    - password: {{ user_pillar['password'] }}

{%       if 'enforce_password' in user_pillar %}
    - enforce_password: {{ user_pillar['enforce_password'] }}
{%       endif %}

{%     endif %}

    - fullname: {{ user_pillar['fullname'] }}

{%     if 'groups' in user_pillar %}
    - groups: {{ user_pillar['groups'] }}
{%     endif %}

    - require:
      - group: {{ user }}
 
{%     if 'key.pub' in user_pillar and user_pillar['key.pub'] == True %}
{{ user }}_key.pub:
  ssh_auth:
    - present
    - user: {{ user }}
    - source: salt://users/{{ user }}/keys/key.pub
{%     endif %}

{%   endif %}

{% endfor %}
