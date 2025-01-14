#!/bin/bash 

# Create key and copy it over
# ssh-keygen -t dsa
# cat /root/.ssh/id_dsa.pub | ssh $OLDPATH "cat >> /root/.ssh/authorized_keys"

# Change Cpanel Settings
#echo maildir=0 >> /var/cpanel/cpanel.config
#echo mysqloldpass=1 >> /var/cpanel/cpanel.config

echo -n "What is the old server's IP? "
read OLDIP

echo "Copying data, this may take a while..."

OPTS="-avxlH --progress -e ssh"

# Etc Directory -- do these first
scp ${OLDIP}:/etc/passwd /etc/passwd
scp ${OLDIP}:/etc/shadow /etc/shadow
scp ${OLDIP}:/etc/group /etc/group
scp ${OLDIP}:/etc/wwwacct.conf /etc/
scp ${OLDIP}:/etc/quota.conf /etc/
scp ${OLDIP}:/etc/demodomains /etc/
scp ${OLDIP}:/etc/userdomains /etc/
scp ${OLDIP}:/etc/trueuserdomains /etc/
scp ${OLDIP}:/etc/trueuserowners /etc/
scp ${OLDIP}:/etc/localdomains /etc/
scp ${OLDIP}:/etc/remotedomains /etc/
scp ${OLDIP}:/etc/domainalias /etc/
scp ${OLDIP}:/etc/vmail /etc/
scp ${OLDIP}:/etc/named.conf /etc/
rsync ${OPTS} ${OLDIP}:/etc/proftpd/ /etc/proftpd/

# Apache
rsync ${OPTS} ${OLDIP}:/usr/local/apache/conf/ /usr/local/apache/conf/
rsync ${OPTS} ${OLDIP}:/usr/local/apache/domlogs/ /usr/local/apache/domlogs/
rsync ${OPTS} ${OLDIP}:/usr/local/frontpage/ /usr/local/frontpage/

# Mr. Radar
rsync ${OPTS} ${OLDIP}:/usr/local/lp/ /usr/local/lp/

# SSL Stuff
rsync ${OPTS} ${OLDIP}:/usr/share/ssl/ usr/share/ssl/

# Mail Stuff
rsync ${OPTS} ${OLDIP}:/etc/valiases/ /etc/valiases/
rsync ${OPTS} ${OLDIP}:/etc/vfilters/ /etc/vfilters/
rsync ${OPTS} ${OLDIP}:/usr/local/cpanel/3rdparty/mailman/ /usr/local/cpanel/3rdparty/mailman/

# Var Stuff
rsync ${OPTS} ${OLDIP}:/var/spool/ /var/spool/
rsync ${OPTS} ${OLDIP}:/var/cpanel/ /var/cpanel/
rsync ${OPTS} ${OLDIP}:/var/named/ /var/named/

# Root user directory
rsync -avHx --exclude=.ssh/ ${OLDIP}:/root/ /root/

# Home directories
rsync -avxH --exclude=virtfs/ ${OLDIP}:/home/* /home/
 
# MySQL Data
rsync ${OPTS} ${OLDIP}:/var/lib/mysql/* /var/lib/mysql/

# Cpanel Skins
rsync -av $OLDIP:/usr/local/cpanel/base/frontend/ /usr/local/cpanel/base/frontend/

echo "Rsync done, running updates..."

/scripts/updateuserdomains
/scripts/upcp

/scripts/easyapache --build

# Copy network info
scp ${OLDIP}:/etc/ips /etc/
scp ${OLDIP}:/etc/ipaddresspool /etc/
scp ${OLDIP}:/etc/services /etc/
# Firewall config
rsync -av $OLDIP:/etc/apf/ /etc/apf/

echo
echo -e "Server cloning done, please review things and run 'netconfig' to update the server IP, then reboot."
echo

