# MastodonUpdateScript
## 概要
Mastodonのインストール＆アップデートをよしなにしてくれるもの

基本的に、[公式ドキュメント](https://github.com/tootsuite/documentation/blob/master/Running-Mastodon/Production-guide.md)通りにインスタンスを設置します。

独自実装などをしているなどの場合は適宜書き換えてご使用ください。

## Mastodonのインストール

まず、`git clone` し、作成した `script` ディレクトリに移動します。

```
git clone https://github.com/S-H-GAMELINKS/MastodonScript.git script　&& cd script
```

次に、`env_setting.sh` を実行し、`mastodon`アカウントを作成

```
sh env_setting.sh
```

作成した`mastodon`アカウントに切り替え、`git clone`を実行。
同様に、`script`ディレクトリに移動します。

```
su - mastodon
git clone https://github.com/S-H-GAMELINKS/MastodonScript.git script　&& cd script
```

rbenvをインストールする`shell`を実行。

```
sh rbenv_install.sh
```

その後、一旦`bash`を再起動。

```
exec bash
```

そして、Rubyをインストールする。

```
sh ruby_install.sh
```

Mastodonのリポジトリを`clone`し、`bundle install`とかをしてくれる`mastodon_install.sh`を実行。

```
sh mastodon_install.sh
```

そのあと、`root`に戻って`setup_postgres_and_ssl.sh`を実行する。
この時、引数に設定したいドメインを渡すこと

```
exit
sh setup_postgres_and_ssl.sh <ドメイン> 
```

`postgres`が起動するので、以下のコマンドを入力。

```
CREATE USER mastodon CREATEDB;
\q
```

また、`vi`が起動した際には、以下の内容を編集して貼り付けること

```
map $http_upgrade $connection_upgrade {
  default upgrade;
  ''      close;
}

server {
  listen 80;
  listen [::]:80;
  server_name <ドメイン>;
  root /home/mastodon/live/public;
  # Useful for Let's Encrypt
  location /.well-known/acme-challenge/ { allow all; }
  location / { return 301 https://$host$request_uri; }
}

server {
  listen 443 ssl http2;
  listen [::]:443 ssl http2;
  server_name <ドメイン>;

  ssl_protocols TLSv1.2;
  ssl_ciphers HIGH:!MEDIUM:!LOW:!aNULL:!NULL:!SHA;
  ssl_prefer_server_ciphers on;
  ssl_session_cache shared:SSL:10m;

  ssl_certificate     /etc/letsencrypt/live/<ドメイン>/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/<ドメイン>/privkey.pem;

  keepalive_timeout    70;
  sendfile             on;
  client_max_body_size 8m;

  root /home/mastodon/live/public;

  gzip on;
  gzip_disable "msie6";
  gzip_vary on;
  gzip_proxied any;
  gzip_comp_level 6;
  gzip_buffers 16 8k;
  gzip_http_version 1.1;
  gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

  add_header Strict-Transport-Security "max-age=31536000";

  location / {
    try_files $uri @proxy;
  }

  location ~ ^/(emoji|packs|system/accounts/avatars|system/media_attachments/files) {
    add_header Cache-Control "public, max-age=31536000, immutable";
    try_files $uri @proxy;
  }
  
  location /sw.js {
    add_header Cache-Control "public, max-age=0";
    try_files $uri @proxy;
  }

  location @proxy {
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto https;
    proxy_set_header Proxy "";
    proxy_pass_header Server;

    proxy_pass http://127.0.0.1:3000;
    proxy_buffering off;
    proxy_redirect off;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $connection_upgrade;

    tcp_nodelay on;
  }

  location /api/v1/streaming {
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto https;
    proxy_set_header Proxy "";

    proxy_pass http://127.0.0.1:4000;
    proxy_buffering off;
    proxy_redirect off;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $connection_upgrade;

    tcp_nodelay on;
  }

  error_page 500 501 502 503 504 /500.html;
}
```

再び、`mastodon`アカウントに戻って、Mastodonの諸設定を実行する。

```
su - mastodon
cd script
sh setup_mastodon.sh
```

セットアップが終了後、`root`に戻って`setup_service.sh`を実行し、Mastodonのインストールは終了。

```
sh setup_service.sh
```

途中、viが起動するの以下の内容をそれぞれの`.service`に張り付ける。

```
[Unit]
Description=mastodon-web
After=network.target

[Service]
Type=simple
User=mastodon
WorkingDirectory=/home/mastodon/live
Environment="RAILS_ENV=production"
Environment="PORT=3000"
ExecStart=/home/mastodon/.rbenv/shims/bundle exec puma -C config/puma.rb
ExecReload=/bin/kill -SIGUSR1 $MAINPID
TimeoutSec=15
Restart=always

[Install]
WantedBy=multi-user.target
```

```
[Unit]
Description=mastodon-sidekiq
After=network.target

[Service]
Type=simple
User=mastodon
WorkingDirectory=/home/mastodon/live
Environment="RAILS_ENV=production"
Environment="DB_POOL=5"
ExecStart=/home/mastodon/.rbenv/shims/bundle exec sidekiq -c 5 -q default -q mailers -q pull -q push
TimeoutSec=15
Restart=always

[Install]
WantedBy=multi-user.target
```

```
[Unit]
Description=mastodon-streaming
After=network.target

[Service]
Type=simple
User=mastodon
WorkingDirectory=/home/mastodon/live
Environment="NODE_ENV=production"
Environment="PORT=4000"
ExecStart=/usr/bin/npm run start
TimeoutSec=15
Restart=always

[Install]
WantedBy=multi-user.target
```

## Mastodonのアップデート

同梱されている`update.sh`を`mastodon`アカウントで実行すればアップデートは自動的に処理されます。

```
su - mastodon
cd script
sh update.sh
```

アップデート終了後、`root`へ戻り、Mastodonを再起動します。

```
exit
sudo systemctl restart mastodon-*.service
```

環境によっては足りないライブラリなどがあると思うので、それらは適宜インストールしてご利用ください。


## 参考

[ゼロからはじめるMastodon インスタンス運用編](https://knowledge.sakura.ad.jp/8683/)

[Mastodon Production Guide](https://github.com/tootsuite/documentation/blob/master/Running-Mastodon/Production-guide.md)
