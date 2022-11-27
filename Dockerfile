FROM alpine:edge

COPY . /root/.config/nvim

WORKDIR /project

RUN apk --no-cache add git neovim bash nodejs npm ripgrep alpine-sdk shfmt black py3-pip && \
  npm install -g pyright bash-language-server dockerfile-language-server-nodejs prettier @fsouza/prettierd && \
  pip install proselint

ENTRYPOINT ["bash"]
