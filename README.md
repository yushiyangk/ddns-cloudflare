# ddns-cloudflare

Dynamic DNS updater for Cloudflare

## Installing

1. Ensure that `curl` and `jq` are installed and accessible on the system `PATH`

2. Install `ddns-cloudflare` to `/opt/ddns-cloudflare`

3. Ensure that only the root user has execute permissions

	```bash
	sudo chown -R root: /opt/ddns-cloudflare
	sudo chmod -R go-wx /opt/ddns-cloudflare
	sudo chmod u+x /opt/ddns-cloudflare/ddns-cloudflare
	```

4. Ensure that `/opt/ddns-cloudflare` is added to the `PATH` environment variable (or add `/opt/bin` to `PATH` and add a symlink to `/opt/ddns-cloudflare/ddns-cloudflare`)

### Configuring

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

## Running

Run

```
ddns-cloudflare
```

Run `ddns-cloudflare -q` or `ddns-cloudflare -qq` to reduce output verbosity. Run `ddns-cloudflare -h` for more information.

### Scheduling

To run the dynamic DNS updater at regular intervals, run `sudo crontab -e` and add the following
<code><pre>*/<var>interval</var> * * * * /etc/opt/ddns-cloudflare -qq</pre></code>

This runs `ddns-cloudflare` every <code><var>interval</var></code> minutes.
