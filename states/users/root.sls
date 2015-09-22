root:
 user.present:
   - fullname: root
   - password: 'foo'
   - shell: /bin/bash
   - home: /root
   - uid: 0
   - gid: 0
   - groups:
     - wheel
     - bin
     - daemon
     - sys
     - adm
     - disk
