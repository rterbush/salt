create_win_logonscript:
  - file.managed:
    - name: C:\salt\bin\user-login.bat
    - source: salt://{{ slspath }}/files/windows-login-script.txt

set_winlogon_autoadminlogon:
  reg.present:
    - name: 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
    - vname: AutoAdminLogon
    - vtype: REG_SZ
    - vdata: 1

set_winlogon_defaultdomainname:
  reg.present:
    - name: 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
    - vname: DefaultDomainName
    - vtype: REG_SZ
    - vdata: 1

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

TS:
  user.present:
    - fullname: TradeStation User
    - password: {{pillar['userpass']}}
    - groups:
      - Users
      - Power Users
    - win_homedrive: 'C:'
    - win_logonscript: C:\salt\bin\user-login.bat