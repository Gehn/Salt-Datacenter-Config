base:
################################################
# This component will get pushed to ALL hosts. #
################################################
  '*':
    - common


##########################################################################
# This component ensures that all states identified by pillar roles get  #
# synced with the client in question, that will not be synced via grains.#
##########################################################################
# TODO: doing it like this as part of '*' is pretty bad.  should probably
# use the pillar match semantics once I figure out what those are -.-

  {% set list_master = salt['cp.list_master']() %}
  {% set my_hostname = grains['host'] %}
  {% set grain_roles = [] %}

  {% if 'roles' in grains: %}
  {%   set grain_roles = grains['roles'] %}
  {% endif %}
  
  {% for pillar_role in salt['pillar.get']('machines:' + my_hostname + ':roles', []): %}
  {%   if "roles/" + pillar_role + '.sls' in list_master and pillar_role not in grain_roles: %}
    - roles.{{ pillar_role }}
  {%   endif %}
  {% endfor %}


##############################################################
# This component ensures that all hosts auto-load any states #
# idenfied by their hostname.                                #
##############################################################

  {% if "machines/" + my_hostname + '.sls' in list_master: %}
  'host:{{ my_hostname }}':
    - match: grain
    - machines.{{ my_hostname }}
  {% endif %}


################################################################
# This component is basically an example of how to deploy to a #
# certain subnet.                                              #
################################################################

#Note: only deprecated now because I deploy the subnet rules
#via roles.  This could be changed if desired; an "exclude"
#directive would probably be needed to not violate the
#generic network configuration in common

#  '128.220.233.0/24':
#    - match: ipcidr
#    - configurations.vbns
#  '172.23.254.0/24':
#    - match: ipcidr
#    - configurations.priv


###############################################################
# This component ensures that all hosts auto-load the states  #
# identified by their roles.                                  #
###############################################################

# TODO: determine if role exists as a state before running it.
# NOTE: right now it will error if a <role>.sls file does not exists for a given role.
# NOTE: the if is due to "roles" being a custom grain; I'd like to be backwards compatible.
  {% if 'roles' in grains: %}
  {%   for my_role in grains['roles']: %}
  {%     if "roles/" + my_role + '.sls' in list_master: %}
  'roles:{{ my_role }}':
    - match: grain
    - roles.{{ my_role }}
  {%     endif %}
  {%   endfor %}
  {% endif %}



