This is the sourcecode behind flightlessmango.com/ website.

# Deploy

## Using docker-compose

1. Prepara data:
```sh
mkdir -p data/db data/storage
export UID=$UID
export GID=$GID
```

2. Start app:
```sh
docker-compose up -d
```

3. Setup database and create users:
```sh
docker-compose exec app rake db:setup
#then create user
docker-compose exec app rails c
> User.create(email: "admin@admin.com", username: "admin", admin: true, password: "1234")
> User.create(email: "user@user.com", username: "user", admin: false, password: "1234")
# you can also create some games:
> Game.create(name: "game1", source: "xxx", image_url: "https://github.com/flightlessmango/flightlessmango.com/raw/master/app/assets/images/mangoLogoSmall.png")
```

4. Finally connect to http://127.0.0.1:3000.

## On host

```sh
git clone https://github.com/flightlessmango/flightlessmango.com && cd flightlessmango.com

# install rvm
curl -sSL https://get.rvm.io | bash

# you also need to install gcc make postgresql yarn python2

# install ruby
rvm install ruby-2.6.4

# - restart the shell to make rvm work as intended
# switch to projects ruby version
rvm use 2.6.4

# install the ruby gems
bundle

# some more dependencies
yarn

# add some required folders
mkdir -p shared/log shared/pids shared/sockets

# initialize postgresql and create a user
# cf https://wiki.archlinux.org/index.php/PostgreSQL#Initial_configuration

# load database migrations
rake db:setup

# run the server
rails s
```

Then create an admin user via rails console `rails c`:
```
User.create(email: "admin@admin.com", username: "admin", admin: true, password: "1234")
```

Finally connect to http://127.0.0.1:3000.
