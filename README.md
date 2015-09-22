# Salt-Datacenter-Config

A highly overengineered salt config setup for a datacenter.  Very specialized for the use case it was written, would not recommend trying to utilize it wholesale out of box, although it might make for good examples/base to hack on.


###################
# Mature features:
###################

-Push authorized keys via configurations.pillar_auth_keys.sls
-Expire authorized keys via configurations.pillar_expire_keys.sls
-Maintain original->*.aside and symlinks via configurations.pillar_aside_and_symlink.sls
-Install and maintain all services in services.*
-Install and maintain all tools in tools.*
-Ensure/change root password via users.root and users.rootpasswd (the former steamrolls the full user)
-Maintain domain settings in network/yp.conf via configurations.pillar_domain_authconfig.sls 
 Override chain: pillar defaults, machine groups, machine specific.
 (NOTE: used to use pillar_domain.sls, authconfig more robust. use None in pillar for domain/server to prevent.)
-Install packages, looking first for a state in packages/, and if not, taking it as a literal package name
 does this derived from pillar fields, via packages.pillar_packages
 Typical machine override chain.
-Install repositories, using the pillar repositories field, via packages.pillar_repositories
 Typical machine override chain.
-Ensure existence of NFS mounts via configurations.pillar_network_mounts.sls
 Same machine pillar overrides.
-sync cups printer files via the cups_printers field via services.pillar_cups_printers
 Typical pillar accumulation/override chain.

#FIXME: always be suspicious of top.sls.  It does way to much for its own good.
The following relies on top.sls via a highstate push. (see Tips section for Test)

-Apply states automatically matching a given host's name. <name>.sls would automatically get applied to <name>
-Apply states automatically matching the roles entry in a given host's grains.
-Apply states automatically matching the roles entry in the machine entry in pillar
-Apply states automatically based on IP configuration/OS/anything else. (this is more raw salt territory.)
- (as part of services.salt-minion) Automatically push grain files matching <hostname>.grain or <role>.grain



###################
# Important files:
###################
top.sls
	Dictates what happens during a state.highstate push to a given node.  See internally for functions.
	Basically, "stuff that should happen based in arbitrary guidelines on ANY host."


#############
# Locations:
#############
./assets
	Files utilized by states (but not states) and related assets should go in their assets folder, in a matching directory structure to the states they are used in.

./states
	State files must go in the states directory, preferrably organized in a meaningful subdirectory.
	States in subdirectories are accessed via <subdirectory>.state.
		states/users: User definitions are here.  See comments in primary users.sls file.
		states/machines: Machine definitions are here. See comments in primary machines.sls.
		states/packages: states for managing packages and repositories.
		states/roles: states triggered by the pillar roles field are stored here.
		states/tools: "tools", things you run that are useful. (e.g. vim.)  This is fuzzy.
		states/configurations: States that manage config files here. (up to interpretation.)
		states/services: States that manage running services go here. Last of the "fuzzy" paths.


./grains
	Grain files to be used for specific machines should be placed in *.grains files in ./grains/ 
	NOTE: this is seperate from ./_grains, which are implicit custom grains copied to all minions during highstate.

	This is done at this point just for organization, it'd be useful to be able to have these accessable to kickstarts to allow for the rest of the deployment to be guided from this information.

./_modules
	Execution modules which will get pushed to any node at a highstate or a sync_all.  Used for
	"Imperative tasks" like moving/symlinking a file, to give a naive example.


#############
# "Gotchas":
#############
variables set via the "set" directive in templating are AGGRESSIVELY SCOPED, and follow
the traditional rules of "shadowing".  (if you do a set in an inner scope on a variable
that was set in the outer scope, when the inner scope exits it will revert to the outer
scoped value)

after modifying an execution module, you must call saltutil.sync_all on the minion to sync the module.

After modifying pillar, you have to restart the minion to sync it.  Refresh_pillar should do this,
but it does not, pending on a bug that's been issued.

After modifying a state, you don't need to do anything.

You can dynamically introspect salt files via cp.list_master, but you cannot dynamically introspect
raw pillar files.

If you use a required stanza (on an sls state), you must include that state prior in the .sls file.
See the pillar_network_mounts for example.

Currently, if you aren't using a pillar field, you should coment out the field label; e.g. "groups:".
This is only due to the salt considering an empty dict a Nontype instead of a list, could be solved
by adding more checks in code, but that's time+clutter that isn't necessarily needed.
FIXME: totally bad form, should really deal with this so it's "hard to be wrong".


#################
# Tips:
#################
It is generally "good form" to make all your states/modules safely re-runnable; and as aggressively
non-destructive as possible.

A good trick to testing if a state is being called properly is just to make it be a file.touch state to some /tmp/testfile.  

Run anything with -ldebug for additional debugging.

Run a state with test=True for a "dry run"
