run_system_updates:
  win_update.installed:
    - categories:
      - 'Critical Updates'
      - 'Security Updates'
