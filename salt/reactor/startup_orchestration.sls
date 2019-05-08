{% set id_or_name = data.id or data.name %}
startup_orchestrate:
  runner.state.orchestrate:
    - mods: orch.startup
    - pillar:
        incoming_id: {{ id_or_name }}
