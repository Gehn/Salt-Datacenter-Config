# TODO: do this in the style of nis domain and keys, where it checks machine_groups as well.
#
#
# Automatically mounts all top level mounts (currently just nfs_mounts) and per machine mounts (machine:nfs_mounts)
# Should in the future do more OS's/mount types, but it'll be the same exact formula.
# FIXME: currently, if you mount the same target in 2 places, it gets confused
# and only persists the latter one as an "update" to the former.  Bug?

{% if grains['os_family'] in ['RedHat']: %}
include:
  - services.nfs

{%   for (nfs_mount, nfs_mount_fields) in (salt['pillar.get']('nfs_mounts', {}).items() + salt['pillar.get']('machines:' + grains['host'] + ':nfs_mounts', {}).items()) %}
{%     if 'mountpoint' and 'target' in nfs_mount_fields: %}

{%	set mountpoint = nfs_mount_fields['mountpoint'] %}
{%	set target = nfs_mount_fields['target'] %}

{{mountpoint}}:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

{{nfs_mount}}:
  mount.mounted:
    - name: {{mountpoint}}
    - device: {{target}}
    - fstype: nfs
    - opts: vers=3
    - persist: True
    - require: 
      - sls: services.nfs

{%     endif %} # if mountpoint and target exist
{%   endfor %} # for nfs_mount in nfs_mounts
{% endif %} # os == SL
