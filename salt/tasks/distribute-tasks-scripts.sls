{%- load_yaml as vars %}
destdir: C:\\temp
{%- endload %}

upload_test_script:
  file.managed:
    - name: {{ vars.destdir }}\test-job-run.py
    - source: salt://{{ slspath }}/scripts/test-job-run.py
    - makedirs: True

