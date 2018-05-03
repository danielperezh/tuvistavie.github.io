---
layout: post
title: Setting up Knowledge repo
tags: [jupyter]
---

I found [Knowledge Repo][1] when looking for a simple tool to
share [Jupyter notebooks][2] and it seemed to fit my needs
so I decided to give it a try.

At the time of writing this article the project is still in beta
and is missing a bit of documentation, so this is a short
tutorial of the steps I used to install Knowledge Repo.

So you know where we are heading, here are a few characteristics
of the installation

* Users login with company's Google account
* Deployed on a Ubuntu VM
* Deployed inside private network --- no big security concerns
* Small team --- no scaling concerns

## Prerequisites

At the time of writing this, Knowledge repo seems to be developed
with Python 3.6 and has some incompatibilities with previous versions,
I therefore suggest to install Python 3.6 before starting.

If you are using Ubuntu, you can use the following commands.

```
sudo add-apt-repository -y ppa:jonathonf/python-3.6
sudo apt-get update
sudo apt-get install -y python3.6
```

## Initial setup

First, we will install Knowledge repo and try to run the server.

```
pip install knowledge_repo[all]
export KNOWLEDGE_REPO="<repo_path>"
knowledge_repo init
knowledge_repo runserver
```

The server should now be accessible at http://localhost:7000

We will now add a dummy Jupyter notebook.

```
knowledge_repo create ipynb test.ipynb
jupyter notebook
```

Edit the notebook if you want.
If you are planning on using Google to authenticate,
edit the authors in the notebook to match the email address
used to login.
Then, add the notebook to the repository.

```
knowledge_repo add -p test test.ipynb
```

The post should now show up in the feed.

### Setting a remote for the repository

The directory created at `<repo_path>` is a git repository,
you should set a remote for it to be able to synchronize later on.

```
cd <repo_path>
git remote add origin git://example.com/my-repo
```

## Configuring a database

The next step is to configure a database, as the default
is in memory SQLite which therefore does not provide persistence.

I used PostgreSQL with [psycopg2][4] but anything which works with
[SQLAlchemy][3] should work just fine.

Create a database and a user for knowledge repo.
Change the following commands for your setup.

```
createuser knowledge_repo -S -D -R -P
createdb -O knowledge_repo knowledge_repo
```

We now fetch the default configuration.

```
wget -O config.py https://raw.githubusercontent.com/airbnb/knowledge-repo/master/knowledge_repo/app/config_defaults.py
```

Then, modify `config.py` to reflect the SQL configuration.
For the above example, assuming MySQL is running on the same server

```python
SQLALCHEMY_DATABASE_URI = 'postgresql+psycopg2://knowledge_repo:password@localhost:5432/knowledge_repo'
```

Finally, stop the server, install PyMySQL and restart the server
with the configuration file.

```
pip install psycopg2-binary
knowledge_repo runserver --config config.py
```

If the server starts properly, hopefully the DB configuration
should be working.

## Configuring authentication

The next step is to configure some sort of authentication.

The steps here are described for OAuth with Google, but the other
providers should work almost the same way.

We will first need to get a client id and secret, for Google
they can be created from [GCP Console][5]

```
AUTH_PROVIDERS = ['google']
OAUTH_GOOGLE_CLIENT_ID = 'CLIENT_ID'
OAUTH_GOOGLE_CLIENT_SECRET = 'CLIENT_SECRET'
```

At this point, if you restart the server
you should be able to use the login functionality.
If you login with the email address you used as
test post author, the user name should be shown instead
of the email address.
The comment functionality should also work when signed in.

### Restricting domains (optional)

If you want users to only be able to login with a particular
domain, you can configure the validation callback in `config.py`.

Here is what mine looks like:

```python
ALLOWED_DOMAINS = ["example.com"]

def OAUTH_GOOGLE_VALIDATE(provider, user):
    domain = user.identifier.split("@")[-1]
    if domain not in ALLOWED_DOMAINS:
        provider.app.logger.warning(
          "User validation failed: login with "
          "invalid domain [{0}]".format(user.identifier))
        return False
    return True
```

### Restricting access to logged in users (optional)

If you want to restrict access to logged in user only,
take a look at the `POLICY_ANONYMOUS_*` variables in
`config.py`.

## Deploying the application

### Setting up supervisor

We will use [supervisor][6] to run the application.
Install supervisor if it is not already installed.
The configuration file, placed at `/etc/supervisor/conf.d/knowledge_repo.conf` looks as follow.

```ini
[program:knowledge_repo]
command = knowledge_repo --config config.py
user = knowledge-repo
directory = /home/knowlege-repo/knowledge-repo
environment=KNOWLEDGE_REPO="/home/knowlege-repo/knowledge-repo",
            OAUTH_GOOGLE_CLIENT_ID="OAUTH_GOOGLE_CLIENT_ID",
            OAUTH_GOOGLE_CLIENT_SECRET="OAUTH_GOOGLE_CLIENT_SECRET",
            SQLALCHEMY_DATABASE_URI="SQLALCHEMY_DATABASE_URI"
```

Adapt the user, directory and environment variables to fit your needs.
Although it is not required, note that I used the environment to pass
in secrets instead of hard coding them in the `config.py` above.

After restarting supervisor, knowledge repo should now be running.

```
sudo systemctl restart supervisor.service
sudo supervisorctl status
```

If the status shows an error, check the logs under `/var/logs/supervisor`.

### Periodically fetching posts

Unfortunately there does not seem to be a good way to update
the knowledge repo, so the simplest way to achieve this is
to periodically pull from the remote repository.
We could probably get something a little better by leveraging
webhooks on commit, but periodically fetching is more than enough
for my use case.

Run `crontab -e` and append the following line:

```
* * * * * cd /home/knowledge-repo/knowledge-repo && git fetch && git reset --hard origin/master
```

Be sure to modify the path for your setup. Note that this will wipe out
any change done on the server side, so do not use this if you plan
to modify files on the server.

### Setting up nginx as a reverse proxy

To take care of serving static assets, caching, gzip and
all this stuff, we are going to set up nginx as a reverse proxy.
Install it with if it is not already present.

Then, create the file `/etc/nginx/sites-available/knowledge_repo.conf` with
the following content.

```
server {
  listen 80;
  server_name example.com;

  gzip on;
  gzip_vary on;
  gzip_min_length 10240;
  gzip_proxied expired no-cache no-store private auth;
  gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml;
  gzip_disable "MSIE [1-6]\.";

  location /static {
    alias /usr/local/lib/python3.6/dist-packages/knowledge_repo/app/static;
  }

  location / {
    proxy_pass http://localhost:7000;

    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

    client_max_body_size 5M;
  }
}
```

Make sure to change `server_name` and the `alias` under `location /static`.
If you are not sure where knowledge repo is installed, hopefully this command
should return the path of the static directory.

```
realpath $(pip show knowledge-repo | grep -i location | awk '{ print $2 }')/knowledge_repo/app/static
```

Then, create a symlink under `/etc/nginx/sites-enabled` and reload nginx.

```
sudo ln -sr /etc/nginx/sites-available/knowledge_repo.conf /etc/nginx/sites-enabled/knowledge_repo.conf
sudo systemctl reload nginx
```

Hopefully everything should now be up and working, and
you should be able to access Knowledge repo through
the domain you set above.

You can follow the [quick start][9] for the client side
and try to push new documents to the knowledge repository.


[1]: http://knowledge-repo.readthedocs.io/en/latest/
[2]: http://jupyter.org/
[3]: https://www.sqlalchemy.org/
[4]: http://initd.org/psycopg/docs/
[5]: https://console.cloud.google.com/apis/credentials
[6]: http://supervisord.org/
[7]: https://letsencrypt.org/
[8]: https://certbot.eff.org/
[9]: http://knowledge-repo.readthedocs.io/en/latest/quickstart.html
