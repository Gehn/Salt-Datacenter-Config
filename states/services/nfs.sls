#TODO: use different domain configurations by subnet.
#TODO: split out which mount configuration to use by some other selector. some grain maybe?

{% if grains['os_family'] in ['RedHat', 'Debian']: %}

/etc/fstab:
  file:
    - touch
# TODO: pull the source, if desired, from pillar.
#    - managed
#    - source: salt://assets/configurations/yp.conf


# Made a choice to do this rather than use a pkg: installed inside nfs.
# This model would utilize putting the package information for a specific include
# inside the state in question.  More abstraction, better modularity, 
# tradeoffs tradeoffs. (also because the require: pkg: 
# stanza for nfs-utils was behaving strangely, and this "just worked")

include:
  - tools.nfs-utils


nfs:
  service:
    - running
    - enable: True
    - watch:
      - file: /etc/fstab

  require:
    - sls: tools.nfs-utils

{% endif %}
