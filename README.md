# Neovim

My neovim configuration, based on NvChad

## Docker

To build from source, run:

```
docker build . -t nvim_docker
```

To install from the command line, run:

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
