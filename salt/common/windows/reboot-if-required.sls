final_housekeeping:
  module.run:
    - system.reboot:
      - only_on_pending_reboot: True
      - order: last
