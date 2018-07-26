sudo -u postgres psql

sudo vi /etc/nginx/sites-available/$1.conf
cd /etc/nginx/sites-enabled
sudo ln -s ../sites-available/$1.conf

sudo systemctl stop nginx

sudo letsencrypt certonly --standalone -d $1

cd /etc/letsencrypt && sudo chmod 777 live && sudo chmod 777 $1

sudo systemctl start nginx
