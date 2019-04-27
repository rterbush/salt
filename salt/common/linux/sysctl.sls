net.ipv4.icmp_echo_ignore_broadcasts:
  sysctl.present:
    - value: 1

net.ipv4.icmp_ignore_bogus_error_responses:
  sysctl.present:
    - value: 1

net.ipv4.tcp_syncookies:
  sysctl.present:
    - value: 1

net.ipv4.conf.all.log_martians:
  sysctl.present:
    - value: 1

net.ipv4.conf.default.log_martians:
  sysctl.present:
    - value: 1

net.ipv4.conf.all.accept_source_route:
  sysctl.present:
    - value: 0

net.ipv4.conf.default.accept_source_route:
  sysctl.present:
    - value: 0

net.ipv4.conf.all.rp_filter:
  sysctl.present:
    - value: 1

net.ipv4.conf.default.rp_filter:
  sysctl.present:
    - value: 1

net.ipv4.conf.all.accept_redirects:
  sysctl.present:
    - value: 0

net.ipv4.conf.default.accept_redirects:
  sysctl.present:
    - value: 0

net.ipv4.conf.all.secure_redirects:
  sysctl.present:
    - value: 0

net.ipv4.conf.default.secure_redirects:
  sysctl.present:
    - value: 0

net.ipv4.ip_forward:
  sysctl.present:
    - value: 0

net.ipv4.conf.all.send_redirects:
  sysctl.present:
    - value: 0

net.ipv4.conf.default.send_redirects:
  sysctl.present:
    - value: 0

net.ipv4.conf.default.proxy_arp:
  sysctl.present:
    - value: 0

net.ipv4.tcp_sack:
  sysctl.present:
    - value: 1

net.ipv6.conf.all.disable_ipv6:
  sysctl.present:
    - value: 1

net.ipv6.conf.all.accept_redirects:
  sysctl.present:
    - value: 0

net.ipv6.conf.default.accept_redirects:
  sysctl.present:
    - value: 0

net.ipv6.conf.all.accept_ra:
  sysctl.present:
    - value: 0

net.ipv6.conf.default.accept_ra:
  sysctl.present:
    - value: 0

kernel.randomize_va_space:
  sysctl.present:
    - value: 2

fs.suid_dumpable:
  sysctl.present:
    - value: 0

net.core.somaxconn:
  sysctl.present:
    - value: 65535
