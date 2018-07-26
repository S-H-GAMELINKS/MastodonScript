sudo su postgres -c 'CREATE USER mastodon CREATEDB;'

sudo vi /etc/nginx/sites-available/$1.conf
cd /etc/nginx/sites-enabled
sudo ln -s ../sites-available/$1.conf

sudo systemctl stop nginx

sudo letsencrypt certonly --standalone -d $1

cd /etc/letsencrypt && sudo chmod 777 live && sudo chmod 777 $1

sudo systemctl start nginx

sudo su -l mastodon "cd ~/live && RAILS_ENV=production bundle exec rake mastodon:setup"

sudo vi /etc/systemd/system/mastodon-web.service
sudo vi /etc/systemd/system/mastodon-sidekiq.service
sudo vi /etc/systemd/system/mastodon-streaming.service

sudo systemctl enable /etc/systemd/system/mastodon-*.service
sudo systemctl start mastodon-*.service
