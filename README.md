# OpenID Connect Implicit Flow Sample Relaying Party
[![Build Status](https://travis-ci.org/hiyosi/oidc-implicit-flow-rp.svg?branch=master)](https://travis-ci.org/hiyosi/oidc-implicit-flow-rp)
[![Coverage Status](https://img.shields.io/coveralls/hiyosi/oidc-implicit-flow-rp.svg)](https://coveralls.io/r/hiyosi/oidc-implicit-flow-rp?branch=master)
[![Code Climate](https://codeclimate.com/github/hiyosi/oidc-implicit-flow-rp/badges/gpa.svg)](https://codeclimate.com/github/hiyosi/oidc-implicit-flow-rp)


This project in reference to 'https://github.com/nov/openid_connect_sample_rp'

OpenID Connect Implicit Flow を実装した Relaying Party のサンプルアプリケーションです。

このアプリケーションは OP として ```hiyosi/tiny-oidc-provider``` と連携するためのサンプルを目的としていますので、
その他OPと連携した場合に正常に動作しない場合があります。


## インストール

````
 $ git clone https://github.com/hiyosi/oidc-implicit-flow-rp.git

 $ oidc-implicit-flow-rp
 
 $ bundle install --path=vendor/bundle
 ````

## 動作確認

1. Rails アプリケーションの起動

  $ CLIENT_ID=<YOUR CLIENT_ID> CALLBACK_URL=<YOUR CALLBACK URL> bundle exec rails s -p 5000


2. ```http://localhost:5000/``` にアクセスして下さい。
