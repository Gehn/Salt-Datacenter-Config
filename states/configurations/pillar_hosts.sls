#!py

########################################################################
#NOTE: this is what the below represents.
#
#{{name1}}:
#  host.present:
#    - ip: {{ip}}
#    - names:
#      - {{name1}}
#      - {{name...}}
#
#NOTE: accumulation/override rules here are a bit "special."
#Ensures that at each more narrow level, names are accumulated for
#each IP, but if there is a duplicate name, it is removed from ip
#the broader layer defines it as.
#
########################################################################

def run():
	state = {}

	hostname = __grains__['host'].split('.')[0]

#Accumulate all hosts.

	default_hosts = __salt__['pillar.get']('hosts', {})
	accumulated_group_hosts = {}

	for group in __salt__['pillar.get']('machines:'+hostname+':groups', []):
		group_hosts = __salt__['pillar.get']('machine_groups:'+group+':hosts', {})
		for (ip, hostnames) in group_hosts.items():
			if ip not in accumulated_group_hosts:
				accumulated_group_hosts[ip] = []
			accumulated_group_hosts[ip].extend(hostnames)

	machine_hosts = __salt__['pillar.get']('machines:'+hostname+':hosts',{})

#Unique by names at proper overrides, then re accumulate under IP's again.

	hosts_by_name = {}

	for (ip, names) in (default_hosts.items() + accumulated_group_hosts.items() + machine_hosts.items()):
		for name in names:
			hosts_by_name[name] = ip

	hosts = {}

	for (name, ip) in hosts_by_name.items():
		if ip not in hosts:
			hosts[ip] = []

		hosts[ip].append(name)

#Now create entries for each IP.

	for (ip, names) in hosts.items():
		
		state[names[0]] = {
			'host.present': [
				{'ip': ip },
				{'names': names},
			],
		}
	
	return state

