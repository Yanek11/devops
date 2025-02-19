# list of changes between default and my version


kk@px:~$ sudo diff -s  /etc/fail2ban/jail.local /etc/fail2ban/jail.conf 
92c92
< ignoreip = 127.0.0.1/8 ::1 138.199.59.0/24 45.134.212.0/24 85.221.131.0/24 5.173.180.0/24  5.173.180.0/24 
---
> #ignoreip = 127.0.0.1/8 ::1
178c178
< #destemail = root@localhost
---
> destemail = root@localhost
181c181
< #sender = root@<fq-hostname>
---
> sender = root@<fq-hostname>
186c186
< #mta = sendmail
---
> mta = sendmail
281,282c281,282
< logpath = %(syslog_authpriv)s
< backend = systemd
---
> logpath = %(sshd_log)s
> backend = %(sshd_backend)s
306d305
< backend = systemd
316d314
< backend = systemd
587,588c585,586
< logpath = %(syslog_mail)s
< backend = systemd
---
> logpath = %(postfix_log)s
> backend = %(postfix_backend)s
