#FIXME: totally mostly a demo.
#FIXME: should make this "generalized" and take pillar arguments, probably?
#Or at least make this such that it gets called as a template from specific tool
#sls files, given that it seems _really_ procedural.
include:
  - packages.nfs


/mnt/gwln1:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

nfs_gwln1:
  mount.mounted:
    - name: /mnt/gwln1
    - device: gwln1.pha.jhu.edu:/export/d0
    - fstype: nfs
    - opts: vers=3
    - persist: True
    - require: 
      - sls: services.nfs
