## -*- docker-image-name: "armbuild/scw-app-docker:latest" -*-
FROM armbuild/scw-distrib-ubuntu:utopic
MAINTAINER Scaleway <opensource@scaleway.com> (@scaleway)

# Prepare rootfs for image-builder
RUN /usr/local/sbin/builder-enter

# Install packages
RUN apt-get -q update                   \
 && apt-get --force-yes -y -qq upgrade  \
 && apt-get --force-yes install -y -q   \
         build-essential zlib1g-dev \
         libyaml-dev libssl-dev \
         libgdbm-dev libreadline-dev \
         libncurses5-dev libffi-dev \
         curl openssh-server \
         redis-server checkinstall \
         libxml2-dev libxslt-dev \
         libcurl4-openssl-dev \
         libicu-dev logrotate \
         python-docutils pkg-config \
         cmake libkrb5-dev nodejs \
         git-core postfix \
         ruby ruby-dev \
         postgresql postgresql-client \
         libpq-dev redis-server nginx

# Install the Bundler gem
RUN gem install bundler --no-ri --no-rdoc

# Creat git user for GitLab
RUN adduser --disabled-login --gecos 'GitLab' git

RUN /etc/init.d/postgresql start \
  && sudo -u postgres psql -d template1 -c 'CREATE USER git CREATEDB;' \
  && sudo -u postgres psql -d template1 -c 'CREATE DATABASE gitlabhq_production OWNER git;'

# Configure redis to use sockets
RUN cp /etc/redis/redis.conf /etc/redis/redis.conf.orig \
  && sed 's/^port .*/port 0/' /etc/redis/redis.conf.orig | sudo tee /etc/redis/redis.conf \
  && echo 'unixsocket /var/run/redis/redis.sock' | sudo tee -a /etc/redis/redis.conf \
  && echo 'unixsocketperm 770' | sudo tee -a /etc/redis/redis.conf \
  && mkdir /var/run/redis \
  && chown redis:redis /var/run/redis \
  && chmod 755 /var/run/redis

# # Persist the directory which contains the socket, if applicable
RUN if [ -d /etc/tmpfiles.d ]; then echo 'd  /var/run/redis  0755  redis  redis  10d  -' | sudo tee -a /etc/tmpfiles.d/redis.conf;  fi

# Add git to the redis group
RUN usermod -aG redis git

# Install GitLab

RUN cd /home/git \
  && sudo -u git -H git clone https://gitlab.com/gitlab-org/gitlab-ce.git -b 7-10-stable gitlab \
  && cd /home/git/gitlab \
  && sudo -u git -H cp config/gitlab.yml.example config/gitlab.yml \
  && chown -R git log/ \
  && chown -R git tmp/ \
  && chmod -R u+rwX,go-w log/ \
  && chmod -R u+rwX tmp/ \
  && sudo -u git -H mkdir /home/git/gitlab-satellites \
  && chmod u+rwx,g=rx,o-rwx /home/git/gitlab-satellites \
  && chmod -R u+rwX tmp/pids/ \
  && chmod -R u+rwX tmp/sockets/ \
  && chmod -R u+rwX  public/uploads \
  && sudo -u git -H cp config/unicorn.rb.example config/unicorn.rb \
  && sudo -u git -H cp config/initializers/rack_attack.rb.example config/initializers/rack_attack.rb \
  && sudo -u git -H cp config/resque.yml.example config/resque.yml

# Configure GitLab DB settings

RUN cd /home/git/gitlab \
  && sudo -u git cp config/database.yml.postgresql config/database.yml \
  && sudo -u git -H chmod o-rwx config/database.yml

RUN chmod 1777 /tmp
# Install Gems

RUN cd /home/git/gitlab \
  && sudo -u git -H bundle install --deployment --without development test mysql aws

# Install GitLab shell

RUN cd /home/git/gitlab \
  && sudo -u git -H bundle exec rake gitlab:shell:install[v2.6.2] REDIS_URL=unix:/var/run/redis/redis.sock RAILS_ENV=production

# Initialize Database and Activate Advanced Features

RUN /etc/init.d/postgresql start \
  && cd /home/git/gitlab \
  && sudo -u git -H force=yes bundle exec rake gitlab:setup RAILS_ENV=production \
  && sudo -u git -H force=yes bundle exec rake assets:precompile RAILS_ENV=production \
  && /etc/init.d/postgresql stop

# Install Init Script and setup logrotate

RUN cd /home/git/gitlab \
  && cp lib/support/init.d/gitlab /etc/init.d/gitlab \
  && update-rc.d gitlab defaults 21 \
  && cp lib/support/logrotate/gitlab /etc/logrotate.d/gitlab

# Nginx site Configuration

RUN cd /home/git/gitlab \
  && cp lib/support/nginx/gitlab /etc/nginx/sites-available/gitlab \
  && ln -s /etc/nginx/sites-available/gitlab /etc/nginx/sites-enabled/gitlab \
  && rm /etc/nginx/sites-enabled/default

# Clean rootfs from image-builder

RUN /usr/local/sbin/builder-leave

