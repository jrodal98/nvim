# Neovim [![Neovim Minimum Version](https://img.shields.io/badge/Neovim-0.7.0-blueviolet.svg?style=flat-square&logo=Neovim&color=90E59A&logoColor=white)](https://github.com/neovim/neovim) [![NVIM Docker Image CI](https://github.com/jrodal98/nvim/actions/workflows/nvim-docker-image.yml/badge.svg)](https://github.com/jrodal98/nvim/actions/workflows/nvim-docker-image.yml)

My neovim configuration, based on [NvChad](https://github.com/NvChad/NvChad). Requires nvim >= v0.7

## Install

If you already have a neovim config, make a backup:

```
mv ~/.config/nvim ~/.config/NVIM.BAK
```

Then run these commands to clone the repository and install nvim packages with Packer

```
git clone https://github.com/jrodal98/nvim ~/.config/nvim
nvim +'hi NormalFloat guibg=#1e222a' +PackerSync
```

You may need to install additional software, such as LSP. See the repo's Dockerfile for other commands you may need to run.

## Docker

I provide docker images for amd64 and arm64. I have tested the images on my thinkpad T470s running Linux as well as a raspberry pi 4 running ubuntu server.

To install from the command line, run:

```
docker pull ghcr.io/jrodal98/nvim:latest
```

If you'd prefer to build from source, run:

```
docker build . -t nvim_docker
```

To run the docker image and to mount the current directory into the spawned container, run:

```
docker run -v $(pwd):/project -it --rm ghcr.io/jrodal98/nvim:latest
```

You can put the following alias in your shell rc:

```
nvim_docker='docker run -v $(pwd):/project -it --rm ghcr.io/jrodal98/nvim:latest'
```

