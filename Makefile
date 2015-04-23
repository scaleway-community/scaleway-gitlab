DOCKER_NAMESPACE =	armbuild/
NAME =			scw-app-gitlab
VERSION =		latest
VERSION_ALIASES =	14.10 14 latest utopic 7.10
TITLE =			GitLab
DESCRIPTION =		GitLab
SOURCE_URL =		https://github.com/scaleway/image-app-gitlab


## Image tools  (https://github.com/scaleway/image-tools)
all:	docker-rules.mk
docker-rules.mk:
	wget -qO - http://j.mp/scw-builder | bash
-include docker-rules.mk


## Here you can add custom commands and overrides

