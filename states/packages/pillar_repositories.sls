#!py

#TODO: use pkgrepo.managed as well as the n

########################################################################
#Installs repos on a machine using the following accumulate/override
#rules:
#
#Take first from global defaults, then groups, then machine specific,
#overwriting only if there is a repository entry name collision.
#(NOTE: not the name: field, the name of the entry in pillar)
#
#NOTE: this is what the below generates; for each entry in pillar of:
#    repositories:
#        ----------
#        epel:
#            ----------
#            name: 
#                epel-release
#        pha-custom:
#            ----------
#            name:
#                pha-custom
#            path:
#                salt://assets/packages/pha-custom.repo
#        pha-custom-urltest:
#            ----------
#            name:
#                pha-custom
#            url:
#                file:///yum/gwln1/pha_custom/sl$releasever/$basearch/
#
#NOTE: I made a (probably questionable) choice to use the pillar name
#at the top level to be a "canonical name" that the inner name
#overwrites with some rather strange semantics.  I should maybe rethink
#this at some point in the future... (my original intention was to make
#deduplication be against the c-names, and not try to look deeper than
#that)
#
#(If a url is given)
#
#{{repository}}:
#  pkgrepo.managed:
#    - humanname: {{pillar_repo_entry_name}} FIXME: maybe another field threded through.
#    - baseurl: {{url}}
#    - gpgcheck: 1
# PKGREPO.MANAGED GOES HERE
#
#
#(If a repo file path is given)
#
#/etc/yum.repos.d/{{repo_file_name}}:
#  file:
#    - managed
#    - source: {{repo_path}}
#    - template: jinja
#
#
#(Otherwise try simply doing a raw install.)
#
#{{pillar_repo_entry_name}}:
#  module.run:
#    - name: install_repository.install_repository
#    - repository: {{repository}}
#
#
########################################################################

def run():
	state = {}

	repositories = {}

	hostname = __grains__['host'].split('.')[0]
	list_master = __salt__['cp.list_master']()

	repositories = __salt__['pillar.get']('repositories', {})

	for group in __salt__['pillar.get']('machines:'+hostname+':groups', []):
		
		for (name, repository_data) in __salt__['pillar.get']('machine_groups:'+group+':repositories', {}).items():
			repositories[name] = repository_data

	for (name, repository_data) in __salt__['pillar.get']('machines:'+hostname+':repositories',{}).items():
		repositories[name] = repository_data


	for (name, repository_data) in repositories.items():
		path = None
		repository = name
		url = None
                gpgcheck = 1
		humanname = name

		if repository_data:
			if 'path' in repository_data:
				path = repository_data['path']
			if 'name' in repository_data:
				repository = repository_data['name']
			if 'url' in repository_data:
				url = repository_data['url']
			if 'gpgcheck' in repository_data:
				gpgcheck = repository_data['gpgcheck']
			if 'humanname' in repository_data:
				humanname = repository_data['humanname']

		if path:
			filename = path.rsplit('/',1)
			filename = filename[len(filename)-1]

			state['/etc/yum.repos.d/' + filename] = {
				'file.managed': [
					{'source': path},
					{'template': 'jinja'},
				],
			}
		elif url:
			state[name] = {
				'pkgrepo.managed': [
					{'name': repository},
					{'baseurl': url},
					{'gpgcheck': gpgcheck},
					{'humanname': humanname},
				],
			}
		else:
			state[name] = {
				'module.run': [
					{'name': 'install_repository.install_repository'},
					{'repository': repository},
				],
			}

	return state
