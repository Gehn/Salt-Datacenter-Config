salt-minion:
  0.17.5-2:
    installer: 'salt://repositories/win/salt-minion/Salt-Minion-0.17.5-2-AMD64-Setup.exe'
    full_name: Salt Minion 0.17.5-2
    locale: en_US
    reboot: False
#{% set salt_master = pillar.get('salt_masters', ['172.23.254.31'])[0] %}
#{% set minion_name = grains['host'] %}
#    install_flags: ' /S /master={{ salt_master}} /minion-name={{ minion_name }}'
    install_flags: ' /S /master=172.23.254.31 /minion-name=%COMPUTERNAME%'
    uninstaller: ''
    uninstall_flags: ''
