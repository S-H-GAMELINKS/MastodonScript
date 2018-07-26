
sudo vi /etc/systemd/system/mastodon-web.service
sudo vi /etc/systemd/system/mastodon-sidekiq.service
sudo vi /etc/systemd/system/mastodon-streaming.service

sudo systemctl enable /etc/systemd/system/mastodon-web.service
sudo systemctl enable /etc/systemd/system/mastodon-streaming.service
sudo systemctl enable /etc/systemd/system/mastodon-sidekiq.service

sudo systemctl start mastodon-web.service
sudo systemctl start mastodon-streaming.service
sudo systemctl start mastodon-sidekiq.service
