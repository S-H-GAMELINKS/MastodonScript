sudo su -l mastodon -c "cd ~/live && git fetch && git checkout $(git tag -l | grep -v 'rc[0-9]*$' | sort -V | tail -n 1) && gem install bundler && bundle install --deployment --without development test  && yarn install && RAILS_ENV=production bundle exec rails db:migrate && RAILS_ENV=production bundle exec rake mastodon:maintenance:add_static_avatars && RAILS_ENV=production bundle exec rails assets:precompile
"
sudo systemctl restart mastodon-*.service
