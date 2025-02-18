# list of changes between default and my version

kk@px:~$ sudo diff -u  /etc/fail2ban/jail.local /etc/fail2ban/jail.conf 
--- /etc/fail2ban/jail.local	2025-02-18 05:54:57.663760176 +0100
+++ /etc/fail2ban/jail.conf	2022-11-09 16:46:15.000000000 +0100
@@ -89,7 +89,7 @@
 # "ignoreip" can be a list of IP addresses, CIDR masks or DNS hosts. Fail2ban
 # will not ban a host which matches an address in this list. Several addresses
 # can be defined using space (and/or comma) separator.
-ignoreip = 127.0.0.1/8 ::1 138.199.59.0/24 45.134.212.0/24 85.221.131.0/24 5.173.180.0/24  5.173.180.0/24 
+#ignoreip = 127.0.0.1/8 ::1
 
 # External command that will take an tagged arguments to ignore, e.g. <ip>,
 # and return true if the IP is to be ignored. False otherwise.
@@ -175,15 +175,15 @@
 
 # Destination email address used solely for the interpolations in
 # jail.{conf,local,d/*} configuration files.
-#destemail = root@localhost
+destemail = root@localhost
 
 # Sender email address used solely for some actions
-#sender = root@<fq-hostname>
+sender = root@<fq-hostname>
 
 # E-mail action. Since 0.8.1 Fail2Ban uses sendmail MTA for the
 # mailing. Change mta configuration parameter to mail if you want to
 # revert to conventional 'mail'.
-#mta = sendmail
+mta = sendmail
 
 # Default protocol
 protocol = tcp
@@ -278,8 +278,8 @@
 # See "tests/files/logs/sshd" or "filter.d/sshd.conf" for usage example and details.
 #mode   = normal
 port    = ssh
-logpath = %(syslog_authpriv)s
-backend = systemd
+logpath = %(sshd_log)s
