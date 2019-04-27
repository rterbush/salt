postgresql_software_install:
  pkg.latest:
    - pkgs:
        - postgresql
        - postgresql-server
        - postgresql-contrib
