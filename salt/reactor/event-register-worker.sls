{% if grains['os'] == 'Windows' %}
{% set id_or_name = data.id or data.name %}
register_windows_worker:
  runner.queue.insert:
    - queue: winworker
    - items: '{"node": "{{ id_or_name }}" }'
{% endif %}