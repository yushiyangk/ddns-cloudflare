#!/usr/bin/env bash

# Requires curl, jq

# Yu Shiyang <yu.shiyang@gnayihs.uy>

# Authentication
zoneid=''
authkey=''
authemail=''
# List of domain names to update within the zone
names=('example.net' 'subdomain.example.net' '*.wildcard.example.net')

###

publicip=$( curl -s checkip.dyndns.org | cut -d ':' -f 2 | cut -d '<' -f 1 | cut -d ' ' -f 2 )

echo -e "Detected IP from \e[94mcheckip.dyndns.org\e[39m: \e[97m$publicip\e[39m"

for i in "${names[@]}"; do
	response=$( curl -s -X GET 'https://api.cloudflare.com/client/v4/zones/'"$zoneid"'/dns_records?type=A&name='"${i}" -H 'Content-Type:application/json' -H 'X-Auth-Key:'"$authkey" -H 'X-Auth-Email:'"$authemail" )
	recordip=$( echo "$response" | jq -Mr '.result[0].content' )
	if [ "$recordip" != "$publicip" ]; then
		recordid=$( echo "$response" | jq -Mr '.result[0].id' )
		recordttl=$( echo "$response" | jq -Mr '.result[0].ttl' )
		recordproxied=$( echo "$response" | jq -Mr '.result[0].proxied' )
		code=$( curl -s -o /tmp/ddns-cloudflare.response -w '%{http_code}' -X PUT 'https://api.cloudflare.com/client/v4/zones/'"$zoneid"'/dns_records/'"$recordid" -H 'Content-Type:application/json' -H 'X-Auth-Key:'"$authkey" -H 'X-Auth-Email:'"$authemail" --data '{"type":"A","name":"'"${i}"'","content":"'"$publicip"'","ttl":'"$recordttl"',"proxied":'"$recordproxied"'}' )
		if [ "$code" == 200 ]; then
			echo -e "200: \e[97m${i}\e[39m updated to $publicip"
		else
			echo -e "\e[31m$code: \e[97m${i}\e[31m failed to update\e[39m"
			cat /tmp/ddns-cloudflare.response
			echo
		fi
		rm /tmp/ddns-cloudflare.response
	else
		echo -e "\e[97m${i}\e[39m unchanged; skipped"
	fi
done





