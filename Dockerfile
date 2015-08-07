## -*- docker-image-name: "armbuild/scw-app-gitlab:latest" -*-
FROM armbuild/scw-distrib-ubuntu:trusty
MAINTAINER Scaleway <opensource@scaleway.com> (@scaleway)


# Prepare rootfs for image-builder
RUN /usr/local/sbin/builder-enter


# Install packages
RUN curl -sL https://deb.nodesource.com/setup | sudo bash - \
 && curl https://packages.gitlab.com/gpg.key | apt-key add - \
 && apt-get -q update                   \
 && apt-get --force-yes -y -qq upgrade  \
 && apt-get --force-yes install -y -q   \
    curl openssh-server ca-certificates postfix apt-transport-https

# Install gitlab
RUN curl -o /etc/apt/sources.list.d/gitlab_ce.list "https://packages.gitlab.com/install/repositories/gitlab/raspberry-pi2/config_file.list?os=debian&dist=wheezy" \
  && apt-get -q update \
  && apt-get install gitlab-ce

RUN echo "kernel.shmall = 262144" >> /etc/sysctl.conf
RUN echo "kernel.shmmax = 1073741824" >> /etc/sysctl.conf


ADD ./patches/etc/ /etc/
ADD ./patches/usr/sbin/ /usr/sbin/


# Clean rootfs from image-builder
RUN /usr/local/sbin/builder-leave
