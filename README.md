Official GitLab image on Scaleway
=================================

Scripts to build the official GitLab image on Scaleway

This image is built using [Image Tools](https://github.com/scaleway/image-tools) and depends on the official [Ubuntu](https://github.com/scaleway/image-ubuntu) image.

---

**This image is meant to be used on a C1 server.**

We use the Docker's building system and convert it at the end to a disk image that will boot on real servers without Docker. Note that the image is still runnable as a Docker container for debug or for inheritance.

[More info](https://github.com/scaleway/image-tools#docker-based-builder)

---

Install
-------

Build and write the image to /dev/nbd1 (see [documentation](https://www.scaleway.com/docs/create-an-image-with-docker)

    $ make install

Full list of commands available at: [scaleway/image-tools](https://github.com/scaleway/image-tools/tree/master#commands)

Test
----

On a running instance:

    $ SCRIPT=$(mktemp); curl -s https://raw.githubusercontent.com/scaleway/image-app-gitlab/master/test.bash > $SCRIPT; bash $SCRIPT
