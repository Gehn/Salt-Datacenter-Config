#!py

########################################################################
#TODO: use different domain configurations by subnet.
#
#The below is basically:
#
#/etc/yp.conf:
#  file:
#    - managed
#    - source: salt://assets/services/yp.conf
#    - require:
#      - pkg: ypbind
#    - template: jinja
#    - defaults:
#      domain: {{domain}} (these overrided from defaults, then groups, then machine specific.)
#      server: {{server}}
#
#ypbind:
#  pkg:
#    - installed
#
#  service:
#    - running
#    - watch:
#      - file: /etc/yp.conf
#    - require:
#      - pkg: ypbind
########################################################################

def run():
	state = {}

        hostname = __grains__['host'].split('.')[0]

        default_nis = __salt__['pillar.get']('nis_domain', None)
        group_nis = default_nis

        for group in __salt__['pillar.get']('machines:'+hostname+':groups', []):
                group_nis = __salt__['pillar.get']('machine_groups:'+group+':nis_domain', group_nis)

        machine_nis = __salt__['pillar.get']('machines:'+hostname+':nis_domain',group_nis)


        state['/etc/yp.conf']= {
                'file.managed': [
                        {'source': 'salt://assets/services/yp.conf'},
			{'require': [
					{'pkg': 'ypbind'},
				],
			},
                        {'template': 'jinja' },
                        {'defaults': {
                                'domain': machine_nis['domain'],
                                'server': machine_nis['server'],
                                },
                        },
                ],
        }

	state['include']=['packages.ypbind']
#	state['ypbind']={
#		'pkg': [
#			'installed',
#		],
#		'service': [
#			'running',
#			{'watch': [
#					{'file': '/etc/yp.conf'},
#				],
#			},
#			{'require': [
#					{'pkg': 'ypbind'},
#				],
#			},
#		],
#	}

        return state

