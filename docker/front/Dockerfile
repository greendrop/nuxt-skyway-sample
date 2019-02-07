FROM node:10.7.0-stretch

RUN set -ex \
  && apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y --no-install-recommends locales task-japanese gosu sudo vim less zsh \
  && rm -rf /var/lib/apt/lists/* \
  && echo 'ja_JP.UTF-8 UTF-8' > /etc/locale.gen \
  && locale-gen \
  && update-locale LANG=ja_JP.UTF-8 \
  && cp -p /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
ENV LANG ja_JP.UTF-8
