## Tetrinetx for Docker
[Tetrinet](https://en.wikipedia.org/wiki/TetriNET) is a cross-platform network-enabled Tetris multiplayer game that follows a simple client/server architecture. It is an easy-to-learn, fast, adictive network game. TetinetX is an opensource free implementation of the server that can be downloaded from https://tetrinetx.sourceforge.net

This Docker Image has been created as part of the [Global Azure Bootcamp 2017 - Spain, Madrid](http://azurebootcamp.es), with a fully functional container than can be leveraged in almost any x64 based Linux environment, whatever it is hosted in on-premises or in the cloud.

This Docker Image has the following features:

  * **Image size:** ~35 MB. Lightweight optimized environment provided by [Alpine GNU/Linux](https://www.alpinelinux.org/).
  * **[Tetrinetx](http://tetrinetx.sourceforge.net/) server version:** 1.13.16+qirc1.40, latest stable release available.
  * **nginx**. Lightweight webserver for providing homepage, client download, instructions and winlist publishing.
  * **Exposed ports:** 31457/TCP (tetrinetx game server), 31458/TCP (tetrinetx spec server), 80/TCP (nginx web server).

The image is officially published at [https://hub.docker.com/r/cmilanf/tetrinetx/](https://hub.docker.com/r/cmilanf/tetrinetx/).

## CVE-1999-1060
Tetrinetx has not been maintained in several decades, with the latest stable release dating back to year 1999. This version is affected by [CVE-1999-1060](https://www.cvedetails.com/cve/CVE-1999-1060/):

> Buffer overflow in Tetrix TetriNet daemon 1.13.16 allows remote attackers to cause a denial of service and possibly execute arbitrary commands by connecting to port 31457 from a host with a long DNS hostname.

I highly encourage to run this software isolated with limited privileges.

## Deploying
This image can be launched successfully with the following syntax:
```bash
docker run -p 31457:31457 -p 31458:31458 -p 80:80 -d -h myhostname.com -e OP_PASSWORD=pass4word -e SPEC_PASSWORD=pass4word --name tetrix cmilanf/tetrinetx:latest
```

  * `-p 31457:31457 -p 31458:31458 -p 80:80`. Exposure of the container ports to host machine. Feel free to change this redirection as long as you keep the original EXPOSE.
  * `-d`. Daemonize, so we won't wait for any user input after launching the container.
  * `-h myhostname.com`. **REQUIRED** You have to enter here a FQDN in order for the server to work correctly. It doesn't matter if it doesn't match your actual DNS name.
  * `-e OP_PASSWORD=pass4word`. Administrator password for the server.
  * `-e SPEC_PASSWORD=pass4word`. Password for the spectator server.
  * `--name tetrix`. The name of the container.
  * `cmilanf/tetrinetx`. The name of the image you are deploying.

## Usage
Upon successful launch, you can start using right away the server by pointing your [TetriNET client](https://www.hispamsx.org/tetrinet) to the domain name or IP of your server.

![TetriNET connection screenshot](https://www.hispamsx.org/tetrinet/img/gabtetrinet2.png)

![Game screen](https://www.hispamsx.org/tetrinet/img/tetrinetgab1.jpg)

*Maintainer: Carlos Milán Figueredo*  
*Twitter: [@cmilanf](https://twitter.com/cmilanf)*  
*https://calnus.com - http://www.hispamsx.org*  
*Special thanks to [Beatriz Sebastián Peña](https://www.linkedin.com/in/beatrizsebastian/)*