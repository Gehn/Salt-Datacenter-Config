# State for connecting the specified machine to appropriat network mounts.
# For SL machines (and probably debian, if we run any...) we want to use NFS,
# for example.

# Maybe should be changed to "common network mounts", but whatever.

{% if grains['os_family'] in ['RedHat']: %}
include:
  - services.nfs


{% endif %}
