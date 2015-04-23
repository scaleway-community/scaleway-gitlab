## -*- docker-image-name: "armbuild/scw-app-gitlab:latest" -*-
FROM armbuild/scw-distrib-ubuntu:utopic
MAINTAINER Scaleway <opensource@scaleway.com> (@scaleway)

# Prepare rootfs for image-builder
RUN /usr/local/sbin/builder-enter

# Install packages
RUN apt-get -q update                   \
 && apt-get --force-yes -y -qq upgrade  \
 && apt-get --force-yes install -y -q   \
         postfix

# Install gitlab

RUN wget https://s3-eu-west-1.amazonaws.com/downloads-packages/raspberry-pi/gitlab_7.9.0-omnibus.pi-1_armhf.deb \
  && dpkg -i gitlab_7.9.0-omnibus.pi-1_armhf.deb \
  && gitlab-ctl reconfigure

# Patch rootfs

ADD ./patches/etc/ /etc/

# Clean rootfs from image-builder

RUN /usr/local/sbin/builder-leave

