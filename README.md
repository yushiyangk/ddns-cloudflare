# ddns-cloudflare

Dynamic DNS updater for Cloudflare

## Basic installation

This tool depends on the packages `curl`, `findutils` and `jq`.

1. Ensure that `curl`, `jq` and `xargs` (part of `findutils`) are installed and accessible on `PATH`

2. Install the `ddns-cloudflare` executable file from this repository to `/opt/ddns-cloudflare/` and ensure that it is owned by root with permissions `u+x,o-wx`

4. [Add `/opt/ddns-cloudflare` to `PATH`](#add-optddns-cloudflare-or-optbin-to-sudo-path) (or add `/opt/bin` to `PATH` and add symlink `ln -s /opt/ddns-cloudflare/ddns-cloudflare /opt/bin/ddns-cloudflare`)

### Configure

1. Create config directory at `/etc/opt/ddns-cloudflare`

2. Create the file `/etc/opt/ddns-cloudflare/domains`, owned by root with permissions `o-w`, containing
	<pre><code>domains=<var>list_of_domains</var></code></pre>

	<code><var>list_of_domains</var></code> is a comma-separated list of domains that should be updated. The domains should be fully qualified, may contain asterisks for wildcards, and may optionally be enclosed in single or double quotes.

3. Create the file `/etc/opt/ddns-cloudflare/auth`, owned by root with permissions `go-rwx`, containing
	<pre><code>zoneid=<var>zone_id</var>
	authtoken=<var>api_token</var></code></pre>

	The values may optionally be enclosed in single or double quotes.

	Make sure that only root has read permissions on this file as it contains the API key.

### Run

```
ddns-cloudflare
```

Or run `ddns-cloudflare -q` or `ddns-cloudflare -qq` to reduce output verbosity. Or run `ddns-cloudflare -h` for more information.

### Options

Use `-q` to only print to stdout when the DNS is changed, or when there is an error. Use `-qq` to only print to stdout when there is an error.

Use <code>-w <var>minutes</var></code> to set a tolerance period such that errors will only be printed to stderr if they have been occuring for longer than the set period.

See `ddns-cloudflare --help` for more information.

### Scheduled run

To run the dynamic DNS updater at regular intervals, run `sudo crontab -e` and add the following
<pre><code>*/<var>interval</var> * * * * /opt/ddns-cloudflare/ddns-cloudflare -qq</code></pre>

This runs `ddns-cloudflare` every <code><var>interval</var></code> minutes.

## Docker installation

Run ddns-cloudflare using Docker Compose:

1. Create the working directory at `/srv/docker/ddns-cloudflare`.

2. Copy the contents of `docker/compose` from this repository to the working directory, either manually or by running

	```
	sudo curl -L https://codeload.github.com/yushiyangk/ddns-cloudflare/zip/refs/heads/docker -o ddns-cloudflare.zip && sudo unzip -t ddns-cloudflare.zip
	sudo unzip ddns-cloudflare.zip ddns-cloudflare-docker/docker/compose/*
	sudo find ddns-cloudflare-docker/docker/compose -mindepth 1 -maxdepth 1 -exec mv -n "{}" . \; && sudo rm -r ddns-cloudflare-docker ddns-cloudflare.zip
	```

### Configure

1. [Configure `cron/ddns-cloudflare/domains` and `cron/ddns-cloudflare/auth` as above.](#configure)

2. Edit `env` to set `DDNS_CLOUDFLARE_INTERVAL_MINS`, which determines how frequently the DNS updates will be attempted, in minutes. This should optimally be a number that divides 60 (since it is used as a divisor for cron).

3. If email notifications are required, edit `cron/ssmtp.conf` to point it to the mail server with [the appropriate settings](https://wiki.archlinux.org/title/SSMTP), then set the following values in `env`:

	- **MAIL_DOMAIN**: The fully-qualified domain name that mail should be sent from (not including username)
	- **MAIL_TO**: The recepient address (including username)

4. Set the time zone by editing `timezone` to the appropriate [tz identifier](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones). Alternatively, set it to be the same as the host by symlinking it to `/etc/timezone`, by running `sudo rm timezone && sudo ln -s /etc/timezone timezone`.

### Run

In the working directory, run

```
sudo docker compose up
```

### Start as service on boot

Install the Systemd unit file and enable the service:

```
sudo ln -s /srv/docker/ddns-cloudflare/ddns-cloudflare.service /etc/systemd/system/ddns-cloudflare.service && sudo systemctl daemon-reload
sudo systemctl enable ddns-cloudflare && sudo service ddns-cloudflare start
```

Check the status of the service:

```
sudo service ddns-cloudflare status
```

### Docker without Compose

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

4. [Configure `config/domains` and `config/auth` as above.](#configure)

5. [Configure `env` (and `ssmtp.conf` and `timezone`) as above.](#configure-1)

6. Set up network

	<pre><code>sudo docker network create -t bridge <var>network_name</var></code></pre>

	Set <code><var>network_name</var></code> to `ddns-cloudflare-network` unless otherwise desired.

7. Run the container

	<pre><code>sudo docker run -it -d --rm --init --cap-drop all --cap-add CAP_SETGID --security-opt=no-new-privileges --read-only --mount type=tmpfs,target=/container --mount type=bind,source=<var>working_dir</var>/config,target=/etc/opt/ddns-cloudflare,readonly --mount type=bind,source=<var>working_dir</var>/ssmtp.conf,target=/etc/ssmtp/ssmtp.conf,readonly --network=<var>network_name</var> --env-file=env --env MAIL_TO="$(grep ^root: /etc/aliases | cut -d ' ' -f 2)" --env MAIL_DOMAIN="$(cat /etc/mailname)" --name=<var>container_name</var> <var>image_name</var> <var>arguments</var></code></pre>

	This sets `MAIL_DOMAIN` to the same fully qualified host name of the host and sets `MAIL_TO` to the same address that the host forwards all root mail to. These override the settings in `env`, if any. Alternatively, they can be omitted to use the settings in `env`.

	Set <code><var>container_name</var></code> to `ddns-cloudflare` unless otherwise desired. Note that <code><var>working_dir</var></code> is the current working directory and must be an absolute path, and that <code><var>arguments</var></code> are the arguments for `ddns-cloudflare`.

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
