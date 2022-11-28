FROM alpine:edge

COPY . /root/.config/nvim

WORKDIR /project

RUN apk --no-cache add git neovim bash nodejs npm ripgrep alpine-sdk py3-pip xz

ENTRYPOINT ["bash"]
