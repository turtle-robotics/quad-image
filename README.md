# TURTLE Raspberry Pi Image
Scripts and GitHub Action to build a custom TURTLE Raspberry Pi image. Built with Raspberry Pi [pi-gen](https://github.com/RPi-Distro/pi-gen).

## To Install
Use either [Etcher](https://etcher.balena.io/) or the [Raspberry Pi Imager](https://www.raspberrypi.com/software/) to flash the image to the sd card.


## To Run Pi-Gen Locally
- clone pi-gen in a folder (https://github.com/RPi-Distro/pi-gen)
- on ubuntu make sure to install docker as well as `qemu-user-static` so it can emulate arm
- copy over the contents of the `pi` folder into the pi-gen repository
- run the docker-build.sh script in pi-gen
