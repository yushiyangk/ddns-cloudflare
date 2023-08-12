# ddns-cloudflare

Dynamic DNS updater for Cloudflare

## Install

This tool depends on the packages `curl`, `findutils` and `jq`.

1. Ensure that `curl`, `jq` and `xargs` (part of `findutils`) are installed and accessible on `PATH`

2. Install `ddns-cloudflare` from this repository to `/opt/ddns-cloudflare/`

3. Set permissions

	```bash
	sudo chown -R root: /opt/ddns-cloudflare
	sudo chmod u+x,o-wx /opt/ddns-cloudflare/ddns-cloudflare
	```

4. [Add `/opt/ddns-cloudflare` to `PATH`](#add-optddns-cloudflare-or-optbin-to-sudo-path) (or add `/opt/bin` to `PATH` and add symlink `ln -s /opt/ddns-cloudflare/ddns-cloudflare /opt/bin/ddns-cloudflare`)

### Configure

1. Create config directory at `/etc/opt/ddns-cloudflare`

2. Create the file `domains` in the config directory, containing
	<code><pre>domains=<var>list_of_domains</var></pre></code>

	<code><var>list_of_domains</var></code> is a comma-separated list of domains that should be updated. The domains should be fully qualified, may contain asterisks for wildcards, and may optionally be enclosed in single or double quotes.

3. Ensure that only the root user has write permissions on `domains`

3. Create the file `auth` in the config directory, containing
	<code><pre>zoneid=<var>zone_id</var>
	authtoken=<var>api_token</var></pre></code>

	The values may optionally be enclosed in single or double quotes.

4. Set permissions

	```bash
	sudo chown root: /etc/opt/ddns-cloudflare/{auth,domains}
	sudo chmod o-w /etc/opt/ddns-cloudflare/domains
	sudo chmod go-rwx /etc/opt/ddns-cloudflare/auth
	```

	Make sure that only root has read permissions on `auth` since it contains the API key

## Run

```
ddns-cloudflare
```

Or run `ddns-cloudflare -q` or `ddns-cloudflare -qq` to reduce output verbosity. Or run `ddns-cloudflare -h` for more information.

### Options

Use `-q` to only print to stdout when the DNS is changed, or when there is an error. Use `-qq` to only print to stdout when there is an error.

Use <code>-w <var>time_expression</var></code> to set a tolerance period during which any errors will not be printed to stderr, where <code><var>time_expression</var></code> can be any expression recognisable by the `date` application. For example: `30min`, `'30 min'`, `'2 hours'`, `1day`.

See `ddns-cloudflare --help` for more information.

### Run schedule

To run the dynamic DNS updater at regular intervals, run `sudo crontab -e` and add the following
<code><pre>*/<var>interval</var> * * * * /opt/ddns-cloudflare/ddns-cloudflare -qq</pre></code>

This runs `ddns-cloudflare` every <code><var>interval</var></code> minutes.
