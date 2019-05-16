postgresql_repo_install:
  pkg.installed:
    - source: https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm

postgresql_software_install:
  pkg.latest:
    - pkgs:
        - postgresql
        - postgresql-server
        - postgresql-contrib
