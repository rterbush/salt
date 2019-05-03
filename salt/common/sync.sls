# replicated in reactor
minion_sync_all:
  module.run:
    - saltutil.sync_all:
      - refresh: True

# replicated in reactor
minion_mine_update:
  module.run:
    - mine.update: []

# replicated in reactor
minion_refresh_pillar:
  module.run:
    - saltutil.refresh_pillar: []
