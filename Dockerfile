FROM ubuntu:latest

VOLUME /source

RUN apt-get update -q -q && \
  apt-get install rsnapshot apt-transport-https ca-certificates curl software-properties-common openssh-server net-tools nano less --yes --force-yes 
RUN ssh-keygen -A 
RUN mkdir /run/sshd 
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache ~/.npm
COPY logrotate.d/* /etc/logrotate.d/
COPY startup-script.sh /etc/startup-script.sh
COPY startup-config /root/startup-config
COPY update-cron.sh /root/update-cron.sh
EXPOSE 22
CMD ["/bin/bash","/etc/startup-script.sh"]
