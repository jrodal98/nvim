FROM alpine:edge

COPY . /root/.config/nvim

WORKDIR /project

RUN apk --no-cache add git neovim bash nodejs npm ripgrep alpine-sdk shfmt black && \
  npm install -g pyright bash-language-server dockerfile-language-server-nodejs prettier @fsouza/prettierd && \
  # install packer and plugins. Sleep hack for extra sanity in waiting for packages to install
  nvim --headless -c 'autocmd User PackerComplete sleep 60 | quitall' -c 'silent PackerSync'

ENTRYPOINT ["/usr/bin/nvim"]
