## -*- docker-image-name: "scaleway/gitlab:latest" -*-
FROM scaleway/ruby:amd64-latest
# following 'FROM' lines are used dynamically thanks do the image-builder
# which dynamically update the Dockerfile if needed.
#FROM scaleway/ruby:armhf-latest       # arch=armv7l
#FROM scaleway/ruby:arm64-latest       # arch=arm64
#FROM scaleway/ruby:i386-latest        # arch=i386
#FROM scaleway/ruby:mips-latest        # arch=mips


MAINTAINER Scaleway <opensource@scaleway.com> (@scaleway)


# Prepare rootfs for image-builder
RUN /usr/local/sbin/scw-builder-enter


# Install deps
RUN echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections  \
 && echo "postfix postfix/mailname string localhost" | debconf-set-selections                \
 && curl -sL https://deb.nodesource.com/setup | sudo bash -                                  \
 && curl https://packages.gitlab.com/gpg.key | apt-key add -                                 \
 && apt-get -q update                                                                        \
 && apt-get --force-yes -y -qq upgrade                                                       \
 && apt-get --force-yes install -y -q                                                        \
        curl openssh-server ca-certificates postfix apt-transport-https                      \
 && apt-get clean


# Install gitlab
RUN case "${ARCH}" in                                                                                                     \
  armv7l|armhf|arm)                                                                                                       \
      curl -o /etc/apt/sources.list.d/gitlab_ce.list                                                                      \
          "https://packages.gitlab.com/install/repositories/gitlab/raspberry-pi2/config_file.list?os=debian&dist=wheezy"  \
      && apt-get -q update && apt-get install -y gitlab-ce;                                                               \
    ;;                                                                                                                    \
  amd64|x86_64|i386)                                                                                                      \
      curl -o /etc/apt/sources.list.d/gitlab_ce.list                                                                      \
          "https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/config_file.list?os=ubuntu&dist=trusty"      \
      && apt-get -q update && apt-get install -y gitlab-ce;                                                               \
    ;;                                                                                                                    \
  *) echo "Unhandled architecture"; exit 1 ;;                                                                             \
  esac


COPY ./overlay/ /


# Clean rootfs from image-builder
RUN /usr/local/sbin/scw-builder-leave
