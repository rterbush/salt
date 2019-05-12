enable_service_nfs:
  service.enabled:
    - name: nfs-client.target

enable_service_rpcbind:
  service.enabled:
    - name: rpcbind

disable_service_postfix:
  service.disabled:
    - name: postfix

disable_service_auditd:
  service.disabled:
    - name: auditd.service

dead_service_postfix:
  service.dead:
    - name: postfix

nfsd:
  service.running:
    - enable: True