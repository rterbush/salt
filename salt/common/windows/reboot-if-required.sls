reboot_if_required:
  system.reboot:
    - only_on_pending_reboot: True
    - force_close: True
    - timeout: 10
    - in_seconds: True
