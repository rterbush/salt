C:/Users/Administrator/Downloads/TradeStation\ 9.5\ Setup.exe
  file.managed:
    - source: salt://roles/designproto/files/TradeStation\ 9.5\ Setup.exe

install_ts:
  cmd.script:
    - source: salt://roles/designproto/files/auto-install-tradestation.py
    - shell: python


