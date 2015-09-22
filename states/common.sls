include:

# Ensure the base minion is installed.
  - services.salt-minion




# Ensure root is configured properly (Thus far just PW, feel free to swap in the full root profile steamroller if needed)
  - users.rootpasswd




# Ensure installation of all needed packages.
  - packages.pillar_repositories
  - packages.pillar_packages




# Ensure existence of network mounts (NFS)
  - configurations.pillar_network_mounts




# Ensure properly manipulated directories.
  - configurations.pillar_aside_and_symlink





# Ensure authorized keys.
  - configurations.pillar_auth_keys




# Ensure proper cups printer config files.
  - configurations.pillar_cups_printers




# Ensure the machine is connected to the appropriate domain.

# NOTE: if you want to hook one of the roles (e.g. vbns) to override standard
# pillar accumulation functionality, this is where you'd change your
# flow of execution. (e.g. "if [vbns, priv, prod] not in roles: pillar_domain")


{% if 'roles' not in grains or ('vbns' not in grains['roles'] and 'priv' not in grains['roles'] and 'prod' not in grains['roles']) %}

{%   set pillar_roles = salt['pillar.get']('machines:' + grains['host'] + ':roles', []) %}
{%   if ('vbns' not in pillar_roles and 'priv' not in pillar_roles and 'prod' not in pillar_roles) %}

  - configurations.pillar_domain_authconfig

{%   endif %}

{% endif %}






