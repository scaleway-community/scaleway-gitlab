## -*- docker-image-name: "armbuild/scw-app-gitlab:latest" -*-
FROM armbuild/scw-distrib-ubuntu:trusty
MAINTAINER Scaleway <opensource@scaleway.com> (@scaleway)


# Prepare rootfs for image-builder
RUN /usr/local/sbin/builder-enter


# Install packages
RUN apt-get -q update                   \
 && apt-get --force-yes -y -qq upgrade  \
 && apt-get --force-yes install -y -q   \
         postfix


# Install gitlab
RUN wget -q -O gitlab.deb https://downloads-packages.s3.amazonaws.com/raspberry-pi/gitlab-ce_7.12.0~omnibus%2B20150622131235-1_armhf.deb \
 && dpkg -i gitlab.deb \
 && rm -f gitlab.deb


RUN echo "kernel.shmall = 262144" >> /etc/sysctl.conf
RUN echo "kernel.shmmax = 1073741824" >> /etc/sysctl.conf


ADD ./patches/etc/ /etc/
ADD ./patches/usr/sbin/ /usr/sbin/


# Clean rootfs from image-builder
RUN /usr/local/sbin/builder-leave

