#Ensures parity of /etc/default/useradd, primarily for the /localhome/ functionality
#normally given in useradd -D -b /localhome/

{% if grains['os_family'] in ['RedHat']: %}

/etc/default/useradd:
  file:
    - managed
    - source: salt://assets/configurations/useradd


{% endif %}
