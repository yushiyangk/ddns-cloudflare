# ddns-cloudflare

Dynamic DNS updater for Cloudflare

## Basic installation

This tool depends on the packages `curl`, `findutils` and `jq`.

1. Ensure that `curl`, `jq` and `xargs` (part of `findutils`) are installed and accessible on `PATH`

2. Download the <code>ddns-cloudflare-<var>version</var>-bash.zip</code> release file and extract the `ddns-cloudflare` executable to `/opt/ddns-cloudflare/`

3. Ensure that `/opt/ddns-cloudflare/ddns-cloudflare` is owned by root and has permissions `'u+x,o-wx`

4. [Add `/opt/ddns-cloudflare` to `PATH`](#add-optddns-cloudflare-or-optbin-to-sudo-path) (or add `/opt/bin` to `PATH` and add symlink `ln -s /opt/ddns-cloudflare/ddns-cloudflare /opt/bin/ddns-cloudflare`)

### Configure

1. Create the config directory at `/etc/opt/ddns-cloudflare`

2. For each separate DNS zone that should be updated,

	1. Create a subdirectory at <code>/etc/opt/ddns-cloudflare/<var>zone_name</var></code>, e.g. <code>/etc/opt/ddns-cloudflare/example.com</code>.

		The <code><var>zone_name</var></code> is typically the domain name of the zone, but it does not have to be.

	2. Create the file <code>/etc/opt/ddns-cloudflare/<var>zone_name</var>/domains</code>`, owned by root with permissions `o-w`, containing
		<pre><code>domains=<var>list_of_domains</var></code></pre>

		<code><var>list_of_domains</var></code> is a comma-separated list of domains that should be updated. Each of the domains should be fully qualified, may contain asterisks for wildcards, and may optionally be enclosed in single or double quotes.

		For example,
		```
		domains='example.com', 'subdomain.example.com', '*.wildcard.example.com'
		```

		**Note:** Each of these domains must already have an A record present in Cloudflare DNS. If they are not, first manually add the corresponding A records with an arbitrary dummy IP address, such as `0.0.0.0`. Otherwise, the update operation will fail.

	3. Create the file <code>/etc/opt/ddns-cloudflare/<var>zone_name</var>/auth</code>, owned by root with permissions `go-rwx`, containing
		<pre><code>zoneid=<var>zone_id</var>
		authtoken=<var>api_token</var></code></pre>

		The values may optionally be enclosed in single or double quotes.

		**Warning:** Make sure that only root has read permissions on this file as it contains the API key.

#### Backwards compatibility with single-zone config

For backwards compatibility, the config files at `/etc/opt/ddns-cloudflare/domain` and `/etc/opt/ddns-cloudflare/auth` will also be treated as a separate DNS zone, with an implicit <code><var>zone_name</var></code> of `(default)`. New installations should avoid using this behaviour as it is likely to be deprecated in the future.

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

To install ddns-cloudflare for Docker Compose:

1. Download the <code>ddns-cloudflare-<var>version</var>-docker-compose.zip</code> release file and extract it to `/srv/docker/ddns-cloudflare`

	This can be done on the command-line with

	```sh
	curl -s https://api.github.com/repos/yushiyangk/ddns-cloudflare/releases/latest | grep -F ddns-cloudflare-1. | grep -F docker-compose.zip | grep -F browser_download_url | head -n 1 | cut -d ':' -f 2- | tr -d '"' | sudo wget -q -i - -P /srv/docker/ddns-cloudflare/  # Download latest 1.x release
	sudo unzip /srv/docker/ddns-cloudflare/ddns-cloudflare-*-docker-compose.zip -d /srv/docker/ddns-cloudflare/
	sudo rm /srv/docker/ddns-cloudflare/ddns-cloudflare-*-docker-compose.zip
	```

	If a previous version is already installed, you will be prompted to replace the existing files. Be careful not to clobber the existing `env`.

### Configure

1. [Configure `cron/ddns-cloudflare/domains` and `cron/ddns-cloudflare/auth` as above](#configure), except that the config directory is **`/srv/docker/ddns-cloudflare/cron/ddns-cloudflare`** instead of `/etc/opt/ddns-cloudflare`.

	Alternatively, an existing config at `/etc/opt/ddns-cloudflare` can be used by symlinking to it
	```
	sudo rm -r /srv/docker/ddns-cloudflare/cron/ddns-cloudflare
	sudo ln -s /etc/opt/ddns-cloudflare /srv/docker/ddns-cloudflare/cron/ddns-cloudflare
	```

2. Edit `env` to set `DDNS_CLOUDFLARE_INTERVAL_MINS`, which determines how frequently the DNS updates will be attempted, in minutes. This should optimally be a number that divides 60 (since it is used as a divisor for cron).

3. If email notifications are required, edit `cron/ssmtp.conf` to point it to the mail server with [the appropriate settings](https://wiki.archlinux.org/title/SSMTP), then set the following values in `env`:

	- **MAIL_DOMAIN**: The fully-qualified domain name that mail should be sent from (not including username)
	- **MAIL_TO**: The recepient address (including username)

4. Set the time zone by editing `timezone` to the appropriate [tz identifier](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).

	Alternatively, set it to be the same as the host by symlinking it to `/etc/timezone`
	```
	sudo rm /srv/docker/ddns-cloudflare/timezone
	sudo ln -s /etc/timezone /srv/docker/ddns-cloudflare/timezone
	```

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

1. Create a working directory, e.g. at `/srv/docker/ddns-cloudflare`

2. Build the image

	<pre><code>sudo docker build --force-rm \
		-t <var>image_name</var> \
		--build-arg cache_date="$(date -Idate)" \
		'https://github.com/yushiyangk/ddns-cloudflare.git#release-v1' \
		-f docker/build/Dockerfile</code></pre>

	This will automatically fetch the latest 1.x release and build it. The build argument `cach_date` invalidates the build cache at the end of each day, so that the packages installed from the distribution are up to date with the latest fixes. Set <code><var>image_name</var></code> to `ddns-cloudflare` unless otherwise desired.

3. Download the <code>ddns-cloudflare-<var>version</var>-docker-run.zip</code> release file and extract it to `/srv/docker/ddns-cloudflare`

	This can be done on the command-line with

	```sh
	curl -s https://api.github.com/repos/yushiyangk/ddns-cloudflare/releases/latest | grep -F ddns-cloudflare-1. | grep -F docker-run.zip | grep -F browser_download_url | head -n 1 | cut -d ':' -f 2- | tr -d '"' | sudo wget -q -i - -P /srv/docker/ddns-cloudflare/  # Download latest 1.x release
	sudo unzip /srv/docker/ddns-cloudflare/ddns-cloudflare-*-docker-run.zip -d /srv/docker/ddns-cloudflare/
	sudo rm /srv/docker/ddns-cloudflare/ddns-cloudflare-*-docker-run.zip
	```

	If a previous version is already installed, you will be prompted to replace the existing files. Be careful not to clobber the existing `env`.

4. [Configure `config/domains` and `config/auth` as above.](#configure), except that the config directory is **`/srv/docker/ddns-cloudflare/config`** instead of `/etc/opt/ddns-cloudflare`.

	Alternatively, an existing config at `/etc/opt/ddns-cloudflare` can be used by symlinking to it
	```
	sudo rm -r /srv/docker/ddns-cloudflare/config
	sudo ln -s /etc/opt/ddns-cloudflare /srv/docker/ddns-cloudflare/config
	```

5. [Configure `env` (and `ssmtp.conf` and `timezone`) as above.](#configure-1)

6. Set up network

	<pre><code>sudo docker network create -t bridge <var>network_name</var></code></pre>

	Set <code><var>network_name</var></code> to `ddns-cloudflare-network` unless otherwise desired.

7. Run the container

	<pre><code>sudo docker run -it -d --rm --init \
		--cap-drop all --cap-add CAP_SETGID --security-opt=no-new-privileges --read-only \
		--mount type=tmpfs,target=/container \
		--mount type=bind,source=<var>working_dir</var>/config,target=/etc/opt/ddns-cloudflare,readonly \
		--mount type=bind,source=<var>working_dir</var>/ssmtp.conf,target=/etc/ssmtp/ssmtp.conf,readonly \
		--mount type=bind,source=<var>working_dir</var>/timezone,target=/etc/timezone,readonly \
		--network=<var>network_name</var> \
		--env-file=env \
		--env MAIL_TO="$(grep ^root: /etc/aliases | cut -d ' ' -f 2)" \
		--env MAIL_DOMAIN="$(cat /etc/mailname)" \
		--name=<var>container_name</var> \
		<var>image_name</var> <var>arguments</var></code></pre>

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
