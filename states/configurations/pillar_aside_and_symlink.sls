##########################################################################################
# Moves a file aside, and symlinks a target into the original position, in multiple ways:
# 1. All top level aside_and_symlink entries in pillar are applied
# 2. Machine specific aside_and_symlink entries in pillar are applied.
##########################################################################################

{% if grains['os_family'] in ['RedHat', 'Debian']: %}
{%   set list_master = salt['cp.list_master']() %}


################################################################################
# (Method #1)
# This method applies all default aside_and_symlinks from pillar.
################################################################################

{%   for (key_name, key_map) in salt['pillar.get']('aside_and_symlink', {}).items() %}

{%     set target = key_map['target'] %}
{%     set symlink_source = key_map['symlink_source'] %}

{{key_name}}:
  module.run:
    - name: aside_and_symlink.aside_and_symlink
    - target: {{target}}
    - symlink_source: {{symlink_source}}

{%   endfor %} #For key_map in aside_and_symlink



################################################################################
# (Method #2)
# This section sees if the machine the state is being run on is in pillar,
# and if it is, applies the specified aside_and_symlinks.
################################################################################

{%   for (key_name, key_map) in salt['pillar.get']('machines:' + grains['host'] + ':aside_and_symlink', {}).items() %}

{%     set target = key_map['target'] %}
{%     set symlink_source = key_map['symlink_source'] %}

{{key_name}}:
  module.run:
    - name: aside_and_symlink.aside_and_symlink
    - target: {{target}}
    - symlink_source: {{symlink_source}}

{%   endfor %} # for key_map in users:<user>:authorized_keys

{% endif %} # os_family in RHEL,Debian

