## -*- docker-image-name: "scaleway/gitlab:latest" -*-
FROM scaleway/debian:amd64-jessie
# following 'FROM' lines are used dynamically thanks do the image-builder
# which dynamically update the Dockerfile if needed.
#FROM scaleway/debian:armhf-jessie       # arch=armv7l
#FROM scaleway/debian:arm64-jessie       # arch=arm64
#FROM scaleway/debian:i386-jessie        # arch=i386
#FROM scaleway/debian:mips-jessie        # arch=mips


MAINTAINER Scaleway <opensource@scaleway.com> (@scaleway)


# Prepare rootfs for image-builder
RUN /usr/local/sbin/scw-builder-enter


# Install deps
RUN echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections  \
 && echo "postfix postfix/mailname string localhost" | debconf-set-selections                \
 && curl -Ls https://packages.gitlab.com/gpg.key | apt-key add -                             \
 && apt-get update                                                                           \
 && apt-get --force-yes -y upgrade                                                           \
 && apt-get clean

# Install gitlab
RUN case "${ARCH}" in                                                                                                                  \
  armv7l|armhf|arm)                                                                                                                    \
      curl -sS https://packages.gitlab.com/install/repositories/gitlab/raspberry-pi2/script.deb.sh | bash                              \
    ;;                                                                                                                                 \
  amd64|x86_64|i386)                                                                                                                   \
      curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | bash                                  \
    ;;                                                                                                                                 \
  *) echo "Unhandled architecture"; exit 1 ;;                                                                                          \
  esac

RUN apt-get -q update              \
 && ( \
     while :; do echo -n .; sleep 60; done & \
     apt-get install -y gitlab-ce \
    ) \
 && apt-get clean

COPY ./overlay/ /


# Clean rootfs from image-builder
RUN /usr/local/sbin/scw-builder-leave
