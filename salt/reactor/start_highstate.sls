{% set id_or_name = data.id or data.name %}
highstate_run:
  local.state.highstate:
    - tgt: {{ id_or_name }}
