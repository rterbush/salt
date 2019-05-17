{% if grains['os'] == 'Windows' %}
{% set id_or_name = data.id or data.name %}
register_windows_worker:
  runner.state.orchestrate:
    - mods: orch.register-worker
    - pillar:
        node: {{ id_or_name }}
{% endif %}