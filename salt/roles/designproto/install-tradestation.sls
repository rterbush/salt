upload_ts:
  file.managed:
    - target: 'C:/Users/Administrator/Downloads/TradeStation 9.5 Setup.exe'
    - source: 'salt://roles/designproto/files/TradeStation 9.5 Setup.exe'

install_ts:
  cmd.script:
    - source: salt://roles/designproto/files/auto-install-tradestation.py
    - shell: python
    - require:
      - file: upload_ts


