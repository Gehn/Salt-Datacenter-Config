# State file for connecting an arbitrary machine to the correct domain.
# Currently only works for SL; in which case it uses ypbind.

# FIXME: I think this is deprecated. for pillar_domain.

{% if grains['os_family'] in ['RedHat', 'Debian']: %}
include:
  - services.ypbind
{% endif %}
