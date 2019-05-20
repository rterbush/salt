delete_scheduled_task:
  module.run:
    - task.delete_task:
      - name: scheduled-task
