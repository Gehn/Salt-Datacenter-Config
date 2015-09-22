vim:
  pkg:
    - installed
    {% if grains['os_family'] == 'RedHat' %}
    - name: vim-enhanced
    {% elif grains['os'] == 'Debian' %}
    - name: vim-nox
    {% endif %}

/etc/vimrc:
 file.managed:
    - source: salt://assets/tools/vimrc
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg: vim

