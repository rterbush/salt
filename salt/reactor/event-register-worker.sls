{% set id_or_name = data.id or data.name %}
{% set os = salt.saltutil.runner('mine.get', tgt=id_or_name, fun='os') %}
{% if os[id_or_name] == 'Windows' %}
delete_scheduled_work:
  salt.state:
    - sls: tasks.delete-scheduled-work
    - tgt: {{ id_or_name }}

register_windows_worker:
  runner.queue.insert:
    - queue: winworker
    - items: {{ id_or_name }}
{% endif %}