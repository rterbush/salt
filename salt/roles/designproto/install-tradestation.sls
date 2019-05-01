{%- load_yaml as bits%}
destdir: 'C:/temp'
tsbin: 'TradeStation 9.5 Setup.exe'
srcdir: 'salt://roles/designproto/files'
{%- endload %}

upload_ts:
  file.managed:
    - name: {{ bits.destdir }}/{{ bits.tsbin }}
    - source: {{ bits.srcdir }}/{{ bits.tsbin }}
    - makedirs: True

upload_script:
  file.managed:
    - name: {{ bits.destdir }}/auto-install-tradestation.py
    - source: {{ bits.srcdir }}/auto-install-tradestation.py
    - makedirs: True

install_ts:
  cmd.script_retcode:
    - name: {{ bits.destdir}}/auto-install-tradestation.py
    - shell: python
    - runas: TS
    - require:
      - file: upload_ts

cleanup_ts:
  file.absent:
    - name: {{ bits.destdir }}/{{ bits.tsbin}}
    - require:
      - cmd: install_ts

cleanup_script:
  file.absent:
    - name: {{ bits.destdir }}/auto-install-tradestation.py
    - require:
      - cmd: install_ts
