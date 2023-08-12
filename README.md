# ddns-cloudflare

Dynamic DNS updater for Cloudflare

## Install

This tool depends on the packages `curl`, `findutils` and `jq`.

1. Ensure that `curl`, `jq` and `xargs` (part of `findutils`) are installed and accessible on the system `PATH`

2. Install `ddns-cloudflare` to `/opt/ddns-cloudflare`

3. Ensure that only the root user has execute permissions

	```bash
	sudo chown -R root: /opt/ddns-cloudflare
	sudo chmod -R go-wx /opt/ddns-cloudflare
	sudo chmod u+x /opt/ddns-cloudflare/ddns-cloudflare
	```

4. Ensure that `/opt/ddns-cloudflare` is added to the `PATH` environment variable (or add `/opt/bin` to `PATH` and add a symlink from there to `/opt/ddns-cloudflare/ddns-cloudflare`)

### Configure

1. Create a config directory at `/etc/opt/ddns-cloudflare`

2. Create the file `domains` in the config directory, containing
	<code><pre>domains=<var>list_of_domains</var></pre></code>

	<code><var>list_of_domains</var></code> is a comma-separated list of domains that should be updated. The domains should be fully qualified, may contain asterisks for wildcards, and may optionally be enclosed in single or double quotes.

3. Ensure that only the root user has write permissions on `domains`

	```bash
	sudo chown root: /etc/opt/ddns-cloudflare/domains
	sudo chmod go-wx /etc/opt/ddns-cloudflare/domains
	```

4. Create the file `auth` in the config directory, containing
	<code><pre>zoneid=<var>zone_id</var>
	authtoken=<var>api_token</var></pre></code>

	The values may optionally be enclosed in single or double quotes.

5. Ensure that only the root user has read or write permissions on `auth`

	```bash
	sudo chown root: /etc/opt/ddns-cloudflare/auth
	sudo chmod go-rwx /etc/opt/ddns-cloudflare/auth
	```

## Run

Run

```
ddns-cloudflare
```

Run `ddns-cloudflare -q` or `ddns-cloudflare -qq` to reduce output verbosity. Run `ddns-cloudflare -h` for more information.

### Run schedule

To run the dynamic DNS updater at regular intervals, run `sudo crontab -e` and add the following
<code><pre>*/<var>interval</var> * * * * /etc/opt/ddns-cloudflare -qq</pre></code>

This runs `ddns-cloudflare` every <code><var>interval</var></code> minutes.

## Docker

This runs the ddns-cloudflare service using Docker Compose.

1. Create a working directory, e.g. at `/srv/docker/ddns-cloudflare`.

2. Copy the contents of `docker/run` from the repository into the working directory, either manually or by running

	```
	sudo curl -L https://codeload.github.com/yushiyangk/ddns-cloudflare/zip/refs/heads/docker -o ddns-cloudflare.zip && sudo unzip -t ddns-cloudflare.zip
	sudo unzip ddns-cloudflare.zip ddns-cloudflare-docker/docker/{run,compose}/*
	sudo find ddns-cloudflare-docker/docker/{run,compose} -mindepth 1 -maxdepth 1 -exec mv "{}" . \; && sudo rm -r ddns-cloudflare-docker ddns-cloudflare.zip
	```

3. Edit `compose.env` to set the command line arguments for `ddns-cloudflare`, and edit `.env` to set the runtime environment variables. `DDNS_CLOUDFLARE_PERIOD` determines how frequently the DNS updates will be attempted, in minutes, and should optimally be a number that divides 60 (as it is used to configure a crontab).

	For email notifications, edit `ssmtp.conf` to point it to the mail server with [the appropriate settings](https://wiki.archlinux.org/title/SSMTP), and ensure that the `MAIL_DOMAIN` and `MAIL_TO` environment variables are set, either in `.env` or later with `--env`.

4. Start the service

	```
	sudo docker compose up
	```

### Start service on boot

Install the Systemd unit file and enable the service:

```
sudo ln -s /srv/docker/ddns-cloudflare/ddns-cloudflare.service /etc/systemd/system/ddns-cloudflare.service && sudo systemctl daemon-reload
sudo systemctl enable ddns-cloudflare && sudo service ddns-cloudflare start
```

Check the status of the service:

```
sudo service ddns-cloudflare status
```

### Use Docker without Compose

1. Create a working directory, e.g. at `/srv/docker/ddns-cloudflare`.

2. Build the container

	<pre><code>sudo docker build --force-rm -t <var>image_name</var> --build-arg cache_date="$(date -Idate)" 'https://github.com/yushiyangk/ddns-cloudflare.git#docker' -f docker/build/Dockerfile</code></pre>

	This will automatically fetch the latest version from GitHub and build it. The build argument `cach_date` invalidates the build cache at the end of each day, so that the packages installed from the distribution are up to date with the latest fixes. Set <code><var>image_name</var></code> to `ddns-cloudflare` unless otherwise desired.

3. Copy the contents of `docker/run` from the repository into the working directory, either manually or by running

	```
	sudo curl -L https://codeload.github.com/yushiyangk/ddns-cloudflare/zip/refs/heads/docker -o ddns-cloudflare.zip && sudo unzip -t ddns-cloudflare.zip
	sudo unzip ddns-cloudflare.zip ddns-cloudflare-docker/docker/run/*
	sudo find ddns-cloudflare-docker/docker/run -mindepth 1 -maxdepth 1 -exec mv "{}" . \; && sudo rm -r ddns-cloudflare-docker ddns-cloudflare.zip
	```

	[Configure the `auth` and `domains` files as above.](#configure)

4. Edit `.env` to set the runtime environment variables, or provide them later with the `--env` argument. `DDNS_CLOUDFLARE_PERIOD` determines how frequently the DNS updates will be attempted, in minutes, and should optimally be a number that divides 60 (as it is used to configure a crontab).

	For email notifications, edit `ssmtp.conf` to point it to the mail server with [the appropriate settings](https://wiki.archlinux.org/title/SSMTP), and ensure that the `MAIL_DOMAIN` and `MAIL_TO` environment variables are set, either in `.env` or later with `--env`.

5. Set up network

	<pre><code>sudo docker network create -t bridge <var>network_name</var></code></pre>

	Set <code><var>network_name</var></code> to `ddns-cloudflare-network` unless otherwise desired.

6. Run the container

	<pre><code>sudo docker run -it -d --rm --init --cap-drop all --cap-add CAP_SETGID --security-opt=no-new-privileges --read-only --mount type=tmpfs,target=/etc/crontabs,tmpfs-mode=755 --mount type=bind,source=<var>working_dir</var>/config,target=/etc/opt/ddns-cloudflare,readonly --mount type=bind,source=<var>working_dir</var>/ssmtp.conf,target=/etc/ssmtp/ssmtp.conf,readonly --network=<var>network_name</var> --env-file=.env --env MAIL_TO="$(grep ^root: /etc/aliases | cut -d ' ' -f 2)" --env MAIL_DOMAIN="$(cat /etc/mailname)" --name=<var>container_name</var> <var>image_name</var> <var>arguments</var></code></pre>

	Set <code><var>container_name</var></code> to `ddns-cloudflare` unless otherwise desired. Note that <code><var>working_dir</var></code> is the current working directory and must be an absolute path, and that <code><var>arguments</var></code> are the arguments for `ddns-cloudflare`.

	This sets `MAIL_DOMAIN` to the same as the host and sets `MAIL_TO` to the address that the host forwards all root mail to. These override the settings in `.env` if any. Alternatively, they can be omitted to use the settings in `.env`.

	Add `-d` before the <code><var>image_name</var></code> to run the container in the background.

## Troubleshooting

### Add `/opt/ddns-cloudflare` or `/opt/bin` to sudo `PATH`

The correct place to set the `PATH` environment variable varies by distribution. For Debian, add a new file to `/etc/profiles.d/` containing

<pre><code>PATH="<var>additional_paths</var>:$PATH"</code></pre>

However, this may not work for sudo commands. In that case, run

```bash
sudo visudo
```

and edit the `Defaults secure_path` value.
