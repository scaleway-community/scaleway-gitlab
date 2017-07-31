NAME =			gitlab
VERSION =		latest
VERSION_ALIASES =	
TITLE =			GitLab
DESCRIPTION =		GitLab host your private and public software projects 
SOURCE_URL =		https://github.com/scaleway-community/scaleway-gitlab
DEFAULT_IMAGE_ARCH =	x86_64

IMAGE_VOLUME_SIZE =	50GB
IMAGE_NAME =		GitLab
IMAGE_BOOTSCRIPT =	latest


## Image tools  (https://github.com/scaleway/image-tools)
all:	docker-rules.mk
docker-rules.mk:
	wget -qO - https://j.mp/scw-builder | bash
-include docker-rules.mk
## Here you can add custom commands and overrides

