root_ssh_pubkey:
  ssh_auth:
    - present
    - user: root
    - source: salt://assets/configurations/keys/root.id_rsa.pub
