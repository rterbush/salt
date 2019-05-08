create_win_logonscript:
  file.managed:
    - name: C:/salt/bin/user-logon.bat
    - source: salt://{{ slspath }}/files/windows-logon-script.txt

set_winlogon_autoadminlogon:
  reg.present:
    - name: 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
    - vname: AutoAdminLogon
    - vtype: REG_SZ
    - vdata: '1'

set_winlogon_defaultdomainname:
  reg.present:
    - name: 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
    - vname: DefaultDomainName
    - vtype: REG_SZ
    - vdata: {{ salt['grains.get']('id') | regex_search('^(.*)\..*') | upper }}

set_winlogon_defaultusername:
  reg.present:
    - name: 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
    - vname: DefaultUserName
    - vtype: REG_SZ
    - vdata: TS

set_winlogon_defaultpassword:
  reg.present:
    - name: 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
    - vname: DefaultPassword
    - vtype: REG_SZ
    - vdata: {{pillar['userpass']}}

set_token_filter_policy:
  reg.present:
    - name: 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    - vname: LocalAccountTokenFilterPolicy
    - vtype: REG_DWORD
    - vdata: 1

TS:
  user.present:
    - fullname: TradeStation User
    - password: {{pillar['userpass']}}
    - groups:
      - Users
      - Power Users
      - Administrators
    - win_homedrive: 'C:'
    - win_logonscript: C:\salt\bin\user-logon.bat
    - win_description: "Trade Analysis Account"