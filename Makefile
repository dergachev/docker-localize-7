assets/localize.drupal.org:
	cd assets; git clone https://bitbucket.org/drupalorg-infrastructure/localize.drupal.org.git

assets/authorized_keys:
	ssh-add -L > $@

assets/mysql_root_pass assets/mysql_drupal_pass: %:
	pwgen -1 16 > $@

assets/composer.phar:
	wget -O $@ http://getcomposer.org/composer.phar

assets/localize.drupal.org/settings.local.php: files/settings.local.php assets/localize.drupal.org
	sed -e "s/@@PASSWORD@@/$$(cat assets/mysql_drupal_pass)/" files/settings.local.php \
		> $@

assets/uid:
	id -u > $@
assets/gid:
	id -g > $@

assets/docker_host_ip:
	hostname -I | awk '{print $$1}' > $@

assets_dir:
	mkdir -p assets

assets: assets_dir assets/localize.drupal.org/settings.local.php assets/mysql_root_pass assets/mysql_drupal_pass assets/composer.phar assets/authorized_keys assets/uid assets/gid assets/docker_host_ip

GIT_PULL_OPTS = --rebase
pull:
	git pull $(GIT_PULL_OPTS)
	git -C assets/deploy pull $(GIT_PULL_OPTS)
	git -C sitediff/repo pull $(GIT_PULL_OPTS)

IMAGE = localize-drupal
CONTAINER = localize-drupal
DOCKER_HOSTNAME = docker
SSH_PORT = 9001
HTTP_PORT = 8001
TOMCAT_PORT = 8003
DOC_PORT = 8002
# TOMCAT localhost only for security reasons
PORTS = -p $(HTTP_PORT):80 -p $(SSH_PORT):22 -p 127.0.0.1:$(TOMCAT_PORT):8080 -p $(DOC_PORT):8002
RUN_OPTS = -d
BUILD_OPTS =
RUN = docker run $(PORTS) $(RUN_OPTS) --name=$(CONTAINER)
RUN_CMD =

build: assets
	docker build $(BUILD_OPTS) -t $(IMAGE) .

# launch debug shell in latest (intermediate) image; useful if 'docker build' fails
debug_latest:
	docker run -t -i `docker images -q | head -n 1` /bin/bash

run:
	$(RUN) $(IMAGE) $(RUN_CMD)

rm: stop
	docker rm $(CONTAINER)

start:
	docker start $(CONTAINER)

stop:
	docker stop $(CONTAINER)

SSH_USER = docker
SSH_CMD =
ssh:
	ssh -p $(SSH_PORT) -o ForwardAgent=yes -o NoHostAuthenticationForLocalhost=yes -l $(SSH_USER) localhost $(SSH_CMD)

# Destroys all uncommitted changes, keeps .vagrant folder
clean:
	git clean -ixd -e .vagrant/ :/

# Destroys all containers and caches that aren't running or tagged!
obliterate:
	-docker ps -a -q | sort | xargs docker rm
	-docker images -a | grep "^<none>" | awk '{print $$3}' | xargs docker rmi

drush_uli:
	make drush DRUSH_CMD="uli -l $(DOCKER_HOSTNAME):$(HTTP_PORT)"

DRUSH_CMD =
drush:
	make ssh SSH_CMD="'cd /drupal; drush $(DRUSH_CMD)'"

.PHONY: run build build_no_cache devel stop ssh obliterate clean \
	assets/site-settings assets_dir pull
