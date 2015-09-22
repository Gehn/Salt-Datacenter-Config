###########################################################
# This state will attempt to generate users for all users listed
# in pillar -> machines -> <machinename> -> users
# for the machinename derived from grains['host']
###########################################################

#FIXME: flesh this out with additional user command as needed (requisite groups etc.).
#TODO: 3/12/2014 finish this + test.
#TODO: change all pillar calls to "get"


{% if grains['host'] in pillar['machines'] and 'users' in pillar['machines'][grains['host']] %}

{%   for user in pillar['machines'][grains['host']]['users'] %}

{%     if user in pillar['users']: %}

{%       set user_pillar = pillar['users'][user] %}



{{ user }}:

  group.present:
    - gid: {{ user_pillar['gid'] }}
  user.present:
    - home: {{ user_pillar['home'] }}
    - shell: {{ user_pillar['shell'] }}
    - uid: {{ user_pillar['uid'] }}
    - gid: {{ user_pillar['gid'] }}

{%       if 'password' in user_pillar %}

    - password: {{ user_pillar['password'] }}

{%         if 'enforce_password' in user_pillar %}

    - enforce_password: {{ user_pillar['enforce_password'] }}

{%         endif %}	# if enforce_password in user_pillar

{%       endif %}	# if password in user_pillar

    - fullname: {{ user_pillar['fullname'] }}

{%       if 'groups' in user_pillar %}

    - groups: {{ user_pillar['groups'] }}

{%       endif %} 	# if groups in user_pillar

    - require:
      - group: {{ user }}
 
{%       if 'key.pub' in user_pillar and user_pillar['key.pub'] == True %}

{{ user }}_key.pub:
  ssh_auth:
    - present
    - user: {{ user }}
    - source: salt://users/{{ user }}/keys/key.pub

{%       endif %} 	# if key pub in user_pillar



{%     endif %}		# if user in pillar->users

{%   endfor %} 		# for users in pillar->machine->host

{% endif %} 		# host in machines and users in machines->host.
