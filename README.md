# Neovim [![Neovim Minimum Version](https://img.shields.io/badge/Neovim-0.8.0-blueviolet.svg?style=flat-square&logo=Neovim&color=90E59A&logoColor=white)](https://github.com/neovim/neovim)

![nvim-basic](https://user-images.githubusercontent.com/35352333/204195025-4e037788-d400-4e88-b73d-97d6b49225c8.png)

## Install

If you already have a neovim config, make a backup:

```
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim/ ~/.local/share/nvim.bak
```

Run this command to clone the repository:

```
git clone https://github.com/jrodal98/nvim ~/.config/nvim
```

Next, follow these steps to finish setting up the config:

1. Run `nvim`, which will trigger the initial packersync (you may see errors - this is okay)
2. Close nvim and then run `nvim` again
3. Install null-ls related packages: `MasonInstall prettierd stylua black isort shfmt shellcheck proselint`
4. Wait for all the treesitter and mason LSP configs to download
5. Close nvim

Setup is now complete!

## Docker

### Run instructions

Install:

```
docker pull ghcr.io/jrodal98/nvim:latest
```

To run the docker image and to mount the current directory into the spawned container, run:

```
docker run -v $(pwd):/project -it --rm ghcr.io/jrodal98/nvim:latest
```

You can put the following alias in your shell rc:

```
nvim_docker='docker run -v $(pwd):/project -it --rm ghcr.io/jrodal98/nvim:latest'
```

### Build instructions

First, build a base image

```
docker build . -t ghcr.io/jrodal98/nvim:<version>
```

Next, run a container

```
docker run -it --rm --name nvim_docker_base ghcr.io/jrodal98/nvim:<version>
```

Finally, we must manually complete the build, due to issues with running packer headless.

1. Run `nvim`, which will trigger the initial packersync (you may see errors - this is okay)
2. Close nvim and then run `nvim` again
3. Install null-ls related packages: `MasonInstall prettierd stylua black isort shfmt shellcheck proselint`
4. Wait for all the treesitter and mason LSP configs to download
5. Outside of the container, open another terminal and run this to save the image: `docker container commit --change='ENTRYPOINT ["/usr/bin/nvim"]' nvim_docker_base ghcr.io/jrodal98/nvim:<version>`

To upload it to ghcr without a github action...

1. `docker login ghcr.io`
2. enter github username and access token
3. `docker tag ghcr.io/jrodal98/nvim:<version> ghcr.io/jrodal98/nvim:latest`
4. `docker push ghcr.io/jrodal98/nvim:<version>`
5. `docker push ghcr.io/jrodal98/nvim:latest`

## Showcase

![nvim-basic](https://user-images.githubusercontent.com/35352333/204195025-4e037788-d400-4e88-b73d-97d6b49225c8.png)
![nvim-inlayhints](https://user-images.githubusercontent.com/35352333/204195065-4c8d32b6-5188-4654-a36b-54220af6f0e3.png)
![nvim-diagnostic](https://user-images.githubusercontent.com/35352333/204195098-380b2db8-aa14-4356-b72a-47a361ad3643.png)

## Inspiration

- [nvim-basic-ide](https://github.com/LunarVim/nvim-basic-ide)
- [Neovim-from-scratch](https://github.com/LunarVim/Neovim-from-scratch)
- [NvChad](https://github.com/NvChad/NvChad)
