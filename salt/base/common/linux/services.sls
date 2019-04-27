disable_service_rpcbind:
  service.disabled:
    - name: rpcbind

disable_service_postfix:
  service.disabled:
    - name: postfix

disable_service_nfs:
  service.disabled:
    - name: nfs-client.target

disable_service_salt:
  service.disabled:
    - name: salt-minion.service

disable_service_auditd:
  service.disabled:
    - name: auditd.service

dead_service_rpcbind:
  service.dead:
    - name: rpcbind

dead_service_postfix:
  service.dead:
    - name: postfix

dead_service_nfs:
  service.dead:
    - name: nfs-client.target

dead_service_salt:
  service.dead:
    - name: salt-minion.service

dead_service_auditd:
  service.dead:
    - name: auditd.service
