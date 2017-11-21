# Running oqp.io

[oqp.io](https://oqp.io/en ) is a project intending to build a platform where everybody can put empty homes on the map to get them back on the market.

This repo shows how oqp.io is built with [Docker](https://www.docker.com), using an [image for Drupal](https://hub.docker.com/_/drupal/). It is intended to run in https with a Let's Encrypt certificate, on a [VPS](https://en.wikipedia.org/wiki/Virtual_private_server). The database is in a linked container using the [MariaDB image](https://hub.docker.com/_/mariadb/).

This repo is intended to foster transparency on [oqp.io](https://oqp.io), to give more visibility on how this site is built and operated to the technical users and future users of [oqp.io](https://oqp.io), and to welcome contributions and improvements, so please fork it! It should not be considered as an example or best practice: I'm experimenting and have a very limited technical background.

## Using this dockerfile

The dockerfile comments should give an insight of what they contain/what they're used for. If you're stuck, get in touch, I'll do my best to help!

### Running the containers

I chose to separate functions rather than processes into different containers. This results in two linked containers:
* db-container
  * based on mariadb
* app-container
  * based on the dockerfile

##Get or create cert files
This will run in https, so you need cert files to make it work. If you're on a public server, you can run Let's Encrypt using Docker:
```
docker run -it \
           --rm \
           --net host \
            -v ./certs:/etc/letsencrypt \
            -v /var/lib/letsencrypt:/var/lib/letsencrypt \
            gzm55/certbot certonly --standalone --text -d oqp.io "$@" 
```

If you're not on a public server, you can generate a self-signed certificate using openssl. 

#### Building and running the database container

For performance and ease of backup, a volume is set to store the database on host:

```
docker pull mariadb

docker run --name db-container \
-v ./datadb:/var/lib/mysql \
-v ./dump:/docker-entrypoint-initdb.d \
--env-file=./.env \
-d mariadb
```

#### Building and running the app container

This `run` command creates shared volumes on the host for the following folders: modules, libraries, backups, sites, themes, tmp and log, to keep your installed modules, themes, and media content when starting a new container and to allow backups and logs to be accessed from the host.

Fill in the xxx in the EXAMPLE files and remove .EXAMPLE from the filenames before running.

```
docker build -t oqpio/drupalapp:8.4.x .

docker run --name drupalapp \
-v ./modules:/var/www/html/modules \
-v ./libraries:/var/www/html/libraries \
-v ./backups:/home/backups \
-v ./sites:/var/www/html/sites \
-v ./themes:/var/www/html/themes \
-v ./certs:/etc/letsencrypt/live/oqp.io/ \
-v ./log:/var/log \
--env-file=./.env \
--link db-container \
-p xx.xx.xx.xx:80:80 \
-p xx.xx.xx.xx:443:443 \
-d oqpio/drupalapp:8.4.x
```

## Used modules

oqp.io uses the following Drupal modules:

```
prepopulate
computed_field
geolocation
conditional_fields
imagick
mailsystem
mimemail
colorbox
colorbox_inline
image_effects
auto_nodetitle
email_registration
pwa
token
token_filter
metatag
metatag_mobile
metatag_open_graph
metatag_twitter_cards
metatag_views
anonymous_publishing
anonymous_publishing_cl
honeypot
views_geojson
views_photo_grid
```

## Contributing

You're welcome to submit issues on this setup code or on oqp.io's features, in English or French, or to submit PRs.

## To Do

This could be faster and easier to maintain by:
* switching to FPM & nginx architecture, using certauto module
* using docker-compose

### Thanks

To every tutorial maker, documentation writer, screencaster and forum poster of the web for the hints!
