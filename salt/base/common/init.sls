include:
  - {{ slspath }}.sync
  {% if grains['os'] == 'Windows' %}
  - {{ slspath }}.windows
  {% else %}
  - {{ slspath }}.linux
  {% endif %}
