{%- load_yaml as bits %}
destdir: C:\\temp
{%- endload %}

upload_test_script:
  file.managed:
    - name: {{ bits.destdir }}\test-job-run.py
    - source: salt://{{ slspath }}/scripts/test-job-run.py
    - makedirs: True

