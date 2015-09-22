#!py

########################################################################
#NOTE: this is what the below represents.
#Was written like this because jinja is terrible at doing one thing for 
#a list of things. (group overrides.)

#/etc/sysconfig/network:
#  file:
#    - managed
#    - source: salt://assets/configurations/network
#    - template: jinja
#    - defaults:
#{% set hostname = grains['host'].split('.')[0] %}
#      hostname: {{hostname}}
#      domain: {{Check first in defaults, then in groups, then in machine specific, overriding in order.}}
########################################################################

def run():
	state = {}

	hostname = __grains__['host'].split('.')[0]

	default_nis = __salt__['pillar.get']('nis_domain', None)
	group_nis = default_nis

	for group in __salt__['pillar.get']('machines:'+hostname+':groups', []):
		group_nis = __salt__['pillar.get']('machine_groups:'+group+':nis_domain', group_nis)

	machine_nis = __salt__['pillar.get']('machines:'+hostname+':nis_domain',group_nis)

	state['/etc/sysconfig/network']= {
		'file.managed': [
			{'source': 'salt://assets/configurations/network'},
			{'template': 'jinja' },
			{'defaults': {
				'hostname': hostname,
				'domain': machine_nis['domain']
				},
			},
		],
	}
	
	return state


