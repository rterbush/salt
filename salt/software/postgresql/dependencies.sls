postgresql_repo_install:
  pkg.installed:
    - sources:
      - pgdg-redhat-repo: https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm

postgresql_software_install:
  pkg.latest:
    - pkgs:
        - postgresql96
        - postgresql96-server
        - postgresql96-contrib
