# Deploying localize.drupal.org via docker

Installation instructions
-------------------------

First, clone this repo:

```
cd ~/code/  # or wherever you work...
git clone https://github.com/dergachev/docker-localize-7
cd docker-localize-7
```

Vagrant
-------

If you're not running docker natively (eg you're on OSX), you will need to rely
on the VirtualBox VM defined in the included Vagrantfile.

* install virtualbox (4.3.14 currently) from [https://www.virtualbox.org/wiki/Downloads](https://www.virtualbox.org/wiki/Downloads)
* install vagrant (1.6.3 currently) from [http://www.vagrantup.com/downloads.html](http://www.vagrantup.com/downloads.html)

The `Vagrantfile` specifies 4 cores and 4GB of RAM. Modify if necessary.

To spin up the VM:

```
# starts the VM; will download trusty64.box on first run
vagrant up
vagrant ssh
```

Note: VirtualBox shared folders implementation is too slow to practically run a
Drupal site from. As a result, we recommend to re-clone this repository inside
`/home/vagrant` and proceed there:

```
cd /home/vagrant # or wherever you work...
git clone https://github.com/dergachev/docker-localize-7
cd docker-localize-7
```

Keep in mind that you'll be forced to develop via VIM (after SSHing into your
vagrant VM), or use a tool like [sshfs](http://osxfuse.github.io/) or
[expandrive](http://www.expandrive.com/expandrive).

Furthermore we recommend populating your dotfiles inside `/home/vagrant`, or at
the very least running the following:

```
git config --global user.name "Your Name"
git config --global user.email "email@example.com"
```

For reference, this is the procedure for installing @dergachev's dotfiles:

```
sudo gem install homesick
homesick clone git@git.ewdev.ca:alex/dotfiles.git
homesick symlink dotfiles
```

Populating assets
-----------------

**SQL dump**

First, you'll need to populate the SQL dump appropriately. Get it from @sebcorbin.

```
cp SOMEWHERE assets/drupal.sql.gq
```

Now populate/generate all the other `assets`: 

```
make assets
```

The above mostly initializes credentials/passwords stores them in the following
files, where docker can read them:

```
make assets/mysql_root_pass     # generate using pwgen
make assets/mysql_drupal_pass   # generate using pwgen
```

The following asks your running SSH agent for all public keys, to be later
installed in the docker container's `/root/.ssh/authorized_keys` and
`/home/docker/.ssh/authorized_keys`:

```
make assets/authorized_keys
```

Running docker build
--------------------

Now with our `assets/` folder suitably populated, we're ready to run `docker
build` to build the docker image based on the steps in the Dockerfile:

```
make build
```

The build takes 5-10 minutes to complete. Subsequent build should be faster due
to docker caching, and use of squid-deb-proxy.

Did `docker build` fail? To start a shell inside the image of the interrupted
build:

```
make debug_latest
```

Running the container
---------------------

Once `docker build` succeeded, let's spin up supervisord inside the newly created image

```
make run
docker ps
```

Check out drupal site! (takes a few seconds first time for mysql to warm caches:)

```
# run this from vagrant VM
curl localhost:8001

# run this from your laptop (outside vagrant VM)
# this IP is of the Vagrant VM, as hardcoded in Vagrantfile
echo "192.168.33.10 docker | sudo tee -a /etc/hosts"
curl docker:8001 
```

Now visit [http://docker:8001](http://docker:8001) in your browser and see the new site. 

Interacting with the container
------------------------------

We've added the following useful commands to the Makefile:

```
make ssh           # SSH into the running drupal container, as 'docker' user
make stop          # calls 'docker stop' on container
make rm            # calls 'docker rm' to blow away stopped container
make start         # calls 'docker start' on previously stopped container
make clean         # calls 'git clean' to blow away assets and other uncommitted changes
make obliterate    # reclaims disk space by destroying ALL stopped containers and untagged images
make drush_uli     # get a login link for the admin user
make drush         # run drush command va ssh; accepts `DRUSH_CMD='sqlq show\ tables'`
```
