#!py

########################################################################
# Theoretical replacement for pillar_domain.
# Uses authconfig to better manage domain/server.
#
# authconfig.authconfig:
#  module.run:
#    - enablenis=True #Default
#    - nisserver=gwln1.pha.jhu.edu
#    - nisdomain=dss.pha.jhu.edu
#
########################################################################

def run():
	state = {}

        hostname = __grains__['host'].split('.')[0]

        default_nis = __salt__['pillar.get']('nis_domain', None)
        group_nis = default_nis

        for group in __salt__['pillar.get']('machines:'+hostname+':groups', []):
                group_nis = __salt__['pillar.get']('machine_groups:'+group+':nis_domain', group_nis)

        machine_nis = __salt__['pillar.get']('machines:'+hostname+':nis_domain',group_nis)


	domain = None
	server = None
	if machine_nis:
		if 'domain' in machine_nis:
			domain = machine_nis['domain']
			server = machine_nis['server']


	state['include']=['packages.ypbind']
	state['include']=['packages.autofs']


        state['authconfig.authconfig']= {
                'module.run': [
			{'enablenis': True},
			{'nisdomain': domain},
			{'nisserver': server},
                ],
        }


        return state

