reboot_now:
  system.reboot:
    - only_on_pending_reboot: False
    - force_close: True
    - timeout: 10
    - in_seconds: True