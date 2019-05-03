final_housekeeping:
  module.run:
    - name: system.reboot
    - only_on_pending_reboot: True
    - order: last
