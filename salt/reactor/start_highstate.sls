{% set id_or_name = data.id or data.name %}
{% set os = salt.saltutil.runner('mine.get', tgt=id_or_name, fun='os') %}
highstate_run:
  local.state.highstate:
    - tgt: {{ id_or_name }}

{% if os[id_or_name] == 'Windows' %}
register_windows_worker:
  runner.queue.insert:
    - queue: winworker
    - items: {{ id_or_name }}
{% endif %}