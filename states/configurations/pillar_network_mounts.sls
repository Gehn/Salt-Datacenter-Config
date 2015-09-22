#!py

########################################################################
#NOTE: this is what the below represents.
#Was written like this because jinja is terrible at doing one thing for 
#a list of things. (group overrides.)
#
#include:
#  - services.nfs
#
#{{mountpoint}}:
#  file.directory:
#    - user: root
#    - group: root
#    - mode: 755
#    - makedirs: True
#
#{{nfs_mount}}:
#  mount.mounted:
#    - name: {{mountpoint}}
#    - device: {{target}}
#    - fstype: nfs
#    - opts: vers=3
#    - persist: True
#    - require:
#      - sls: services.nfs
#
########################################################################

def run():
	state = {}
	state['include'] = ['packages.nfs']

	hostname = __grains__['host'].split('.')[0]

	default_nfs = __salt__['pillar.get']('nfs_mounts', {})
	accumulated_group_nfs = {}

	for group in __salt__['pillar.get']('machines:'+hostname+':groups', []):
		group_nfs = __salt__['pillar.get']('machine_groups:'+group+':nfs_mounts', {})
		for (nfs_mount, mount_data) in group_nfs.items():
			accumulated_group_nfs[nfs_mount] = mount_data

	machine_nfs = __salt__['pillar.get']('machines:'+hostname+':nfs_mounts',{})

	for (nfs_mount, mount_data) in default_nfs.items() + accumulated_group_nfs.items() + machine_nfs.items():
		if 'mountpoint' and 'target' not in mount_data:
			continue

		mountpoint = mount_data['mountpoint']
		target = mount_data['target']

		state[mountpoint] = {
			'file.directory': [
				{'user': 'root' },
				{'group': 'root' },
				{'mode': '755' },
				{'makedirs': 'True' },
			],
		}

		state[nfs_mount] = {
			'mount.mounted': [
				{'name': mountpoint},
				{'device': target},
				{'fstype': 'nfs'},
				{'opts': 'vers=3'},
				{'persist': 'True'},
				{'require': [
					{'sls': 'packages.nfs'},
					],
				},
			],
		}

	
	return state

