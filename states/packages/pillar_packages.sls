#!py

########################################################################
#Installs packages on a machine (first attempting to utilize the state
#that federates that package located in states/packages if such a state
#exists) by unifying pillar packages: at the top level, packages: in all
#machine_groups this machine belongs to, and all packages: in the machine
#specific definition.
#
#
#NOTE: this is what the below represents.
#
#	(For packages that exist as states in states/packages/)
#include: 
#  - package1
#  - package2
#
#	(For packages that don't)
#package3:
#  pkg:
#    - installed
#
########################################################################

def run():
	state = {}

	packages = []

	hostname = __grains__['host'].split('.')[0]
	list_master = __salt__['cp.list_master']()

	packages.extend(__salt__['pillar.get']('packages', []))

	for group in __salt__['pillar.get']('machines:'+hostname+':groups', []):
		packages.extend(__salt__['pillar.get']('machine_groups:'+group+':packages', []))

	packages.extend(__salt__['pillar.get']('machines:'+hostname+':packages',[]))


	include_packages = []
	install_packages = []

	for package in set(packages):
		if 'packages/' + package + '.sls' in list_master:
			include_packages.append(package)
		else:
			install_packages.append(package)

	if include_packages:
		state['include'] = []
		for include_package in include_packages:
			state['include'].append('packages.' + include_package)

	if install_packages:
		for install_package in install_packages:
			state[install_package] = {'pkg':['installed']}


	return state


