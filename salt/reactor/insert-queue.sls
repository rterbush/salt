{% set id_or_name = data.id or data.name %}
register_windows_worker:
  runner.state.orchestrate_single:
    - fun: queue.insert
    - name: winworkers
    - pillar:
        node: {{ id_or_name }}