firefox:
  27.0.1:
    installer: 'salt://repositories/win/firefox/Firefox Setup Stub 27.0.1.exe'
    full_name: Mozilla Firefox 27.0.1 (x86 en-US)
    locale: en_US
    reboot: False
    install_flags: ' -ms'
    uninstaller: '%ProgramFiles(x86)%/Mozilla Firefox/uninstall/helper.exe'
    uninstall_flags: ' /S'
