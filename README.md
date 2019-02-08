# nuxt-skyway-sample

SkyWayを使用したビデオチャット(WebRTC)のサンプルです。

## 使用言語・ライブラリ

- SkyWay
- Nuxt.js(Vue.js)
- Vuetify

## 環境構築アプリケーション

- Docker
- Docker Compose
- direnv
- git

## セットアップ

```shell
$ git clone git@github.com:greendrop/nuxt-skyway-sample.git
$ cd nuxt-skyway-sample
$ vi .envrc
$ direnv allow
$ cp .env.example .env
$ docker-compose pull
$ docker-compose build
$ docker-compose run --rm front bash
$ yarn install
$ exit
$ docker-compose up
```

### .envrc

```
export USER_ID=`id -u`
export GROUP_ID=`id -g`
```

### .env

SkyWayのAPIキー

```
API_KEY=XXXXXX
```

## ブラウザで表示

http://localhost:3000
