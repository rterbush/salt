remove_tradestation_registry_key0:
  reg.key_absent:
    - name: HKLM\SOFTWARE\WOW6432Node\TradeStation Technologies

remove_tradestation_registry_key1:
  reg.key_absent:
    - name: HKU\.DEFAULT\Software\TradeStation Technologies

remove_tradestation_registry_key2:
  reg.key_absent:
    - name: HKU\*\Software\TradeStation Technologies

remove_tradestation_registry_key3:
  reg.key_absent:
    - name: HKU\\*\SOFTWARE\TradeStation Technologies

remove_tradestation_registry_key4:
  reg.key_absent:
    - name: HKCU\SOFTWARE\TradeStation Technologies
