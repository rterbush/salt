delete_scheduled_work:
  module.run:
    - task.delete_task:
      - name: scheduled-work
