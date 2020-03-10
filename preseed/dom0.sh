#!/bin/sh

/usr/bin/install -d -m 700 -o root -g root /root/.ssh
/bin/cat << EOF > /root/.ssh/authorized_keys
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIpI3OaNyY8S2jDg4ibT4hRiQwzZTslrysKr1epZEWfh hans.van.kranenburg@mendix.nl
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAje0ghkW9j9yLuidajJZoIvhlKvpodnW+h2jyFPUC/k pim.van.den.berg@mendix.com
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJXA5i/JZf3HDFsxb+zH//uoCBmRyqLS8bPIh/1dncNb maarten.hendrix@mendix.com
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIISKPx8BrmQf8MSMSqRQANhjDQszH/TI3zMcTb05RjXk igor.yurchenko@mendix.com
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMaD3WThJzRzA5GND8m/ztxfWH3T/Ns2XL1h34ZFYp93 cloudops@baron
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILLMc+s2eUMmc5aSjNGwUNPu8UvQFnO347Gp6+iI8ogP cloudops@bofh
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINhTs2ws1y9tD+0QllQCaSp9CfpnAUfSSCTPmvEzgEgu cloudops@pino
EOF

if /bin/grep -q ^8 /etc/debian_version
then
    /bin/ln -nsf /dev/null /etc/systemd/system/puppet.service
else
    /bin/echo "exit 1" >> /etc/default/puppet
fi
/usr/bin/test ! -f /var/lib/puppet/state/agent_disabled.lock || /bin/rm /var/lib/puppet/state/agent_disabled.lock
