# replicated in reactor
minion_sync_all:
  module.run:
    - name: saltutil.sync_all
    - refresh: True

# replicated in reactor
minion_mine_update:
  module.run:
    - name: mine.update

# replicated in reactor
minion_refresh_pillar:
  module.run:
    - name: saltutil.refresh_pillar
