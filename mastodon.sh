# Add mastodon user　
sudo adduser mastodon

# apt update & upgrate
sudo apt update && sudo apt upgrade

# Add node.js Repository
sudo apt -y install curl && sudo curl -sL https://deb.nodesource.com/setup_8.x | sudo bash -

# Add Yarn Repository
sudo curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
sudo echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update

# All need prigram install
sudo apt -y install imagemagick ffmpeg libpq-dev libxml2-dev libxslt1-dev file git-core g++ libprotobuf-dev protobuf-compiler pkg-config nodejs gcc autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev nginx redis-server redis-tools postgresql postgresql-contrib letsencrypt yarn libidn11-dev libicu-dev

sudo su -l mastodon -c  "cd ~ && git clone https://github.com/rbenv/rbenv.git ~/.rbenv && cd ~/.rbenv && src/configure && make -C src"

su - mastodon 

sudo su -l mastodon -c "git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build"

su - mastodon

sudo su -l mastodon -c "cd ~ && git clone https://github.com/tootsuite/mastodon.git live && cd ~/live && git checkout $(git tag -l | grep -v 'rc[0-9]*$' | sort -V | tail -n 1)"

su - mastodon 

sudo -u postgres psql

sudo vi /etc/nginx/sites-available/$1.conf
cd /etc/nginx/sites-enabled
sudo ln -s ../sites-available/$1.conf

sudo systemctl stop nginx

sudo letsencrypt certonly --standalone -d $1

cd /etc/letsencrypt && sudo chmod 777 live && sudo chmod 777 $1

sudo systemctl start nginx

su - mastodon

sudo vi /etc/systemd/system/mastodon-web.service
sudo vi /etc/systemd/system/mastodon-sidekiq.service
sudo vi /etc/systemd/system/mastodon-streaming.service

sudo systemctl enable /etc/systemd/system/mastodon-web.service
sudo systemctl enable /etc/systemd/system/mastodon-streaming.service
sudo systemctl enable /etc/systemd/system/mastodon-sidekiq.service

sudo systemctl start mastodon-web.service
sudo systemctl start mastodon-streaming.service
sudo systemctl start mastodon-sidekiq.service
