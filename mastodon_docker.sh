sudo apt update
sudo apt upgrade

sudo apt install daemon
sudo apt install -y build-essential
sudo apt install git
sudo apt install docker.io
sudo apt install docker-compose
sudo apt install -y libssl-dev libreadline-dev 
sudo apt install letsencrypt

sudo adduser --ingroup docker docker

sudo su -l docker -c  "cd ~ && git clone https://github.com/rbenv/rbenv.git ~/.rbenv && cd ~/.rbenv && src/configure && make -C src"

su - docker

sudo su -l docker -c "git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build"

su - docker

sudo su -l docker -c "cd ~ && git clone https://github.com/tootsuite/mastodon.git live && cd ~/live && git checkout $(git tag -l | grep -v 'rc[0-9]*$' | sort -V | tail -n 1) && vi docker-compose.yml && cp .env.production.sample .env.production && docker-compose pull && docker-compose build"

sudo su -l docker -c "docker-compose run --rm web rake secret && docker-compose run --rm web rake secret && docker-compose run --rm web rake secret"

su - docker

sudo su -l docker -c "cd ~/live && docker-compose run --rm web bundle exec rake mastodon:setup && docker-compose up -d"

sudo vi /etc/nginx/sites-available/$1.conf
cd /etc/nginx/sites-enabled
sudo ln -s ../sites-available/$1.conf

sudo systemctl stop nginx

sudo letsencrypt certonly --standalone -d $1

cd /etc/letsencrypt && sudo chmod 777 live && sudo chmod 777 $1

sudo systemctl start nginx

sudo vi /etc/systemd/system/mastodon-web.service
sudo vi /etc/systemd/system/mastodon-sidekiq.service
sudo vi /etc/systemd/system/mastodon-streaming.service

sudo systemctl enable /etc/systemd/system/mastodon-web.service
sudo systemctl enable /etc/systemd/system/mastodon-streaming.service
sudo systemctl enable /etc/systemd/system/mastodon-sidekiq.service

sudo systemctl start mastodon-web.service
sudo systemctl start mastodon-streaming.service
sudo systemctl start mastodon-sidekiq.service
