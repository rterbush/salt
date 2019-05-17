queue_windows_worker:
  module.run:
    - name: queue.insert
      - queue: winworker
        - items: '{"node:": {{ pillar['node'] }} }'
    - tgt: 'G@os:Windows and {{ pillar['node'] }}'
    - tgt_type: compound