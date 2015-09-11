DOCKER_NAMESPACE =	armbuild/
NAME =			scw-app-gitlab
VERSION =		latest
VERSION_ALIASES =	
TITLE =			GitLab
DESCRIPTION =		GitLab
SOURCE_URL =		https://github.com/scaleway-community/scaleway-gitlab

IMAGE_VOLUME_SIZE =	150GB
IMAGE_NAME =		GitLab
IMAGE_BOOTSCRIPT =	stable


## Image tools  (https://github.com/scaleway/image-tools)
all:	docker-rules.mk
docker-rules.mk:
	wget -qO - http://j.mp/scw-builder | bash
-include docker-rules.mk
## Here you can add custom commands and overrides

