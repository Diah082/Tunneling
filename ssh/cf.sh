#!/bin/bash
sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1
apt install jq curl -y
rm -rf /root/xray/scdomain
mkdir -p /root/xray
clear
IP=$(wget -qO- icanhazip.com);
sub=$(</dev/urandom tr -dc a-z0-9 | head -c5)
subsl=$(</dev/urandom tr -dc a-z0-9 | head -c5)
DO=vpnnewbie.my.id
SUB_DOMAIN=pro-${sub}.vpnnewbie.my.id
NS_DOMAIN=*.${SUB_DOMAIN}.vpnnewbie.my.id
CF_KEY=I1CiYyo8ef3RGSzB-KSR3Q8wMoc3rT9sTJeMEMpp
set -euo pipefail
echo "Pointing Domain for $SUB_DOMAIN..."
ZONE=$(
		curl -sLX GET "https://api.cloudflare.com/client/v4/zones?name=${DO}&status=active" \
		-H "Authorization: Bearer ${CF_KEY}" \
		-H "Content-Type: application/json" | jq -r .result[0].id
	)

	RECORD=$(
		curl -sLX GET "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?name=${SUB_DOMAIN}" \
		-H "Authorization: Bearer ${CF_KEY}" \
		-H "Content-Type: application/json" | jq -r .result[0].id
	)

		RECORD1=$(
		curl -sLX GET "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?name=${NS_DOMAIN}" \
		-H "Authorization: Bearer ${CF_KEY}" \
		-H "Content-Type: application/json" | jq -r .result[0].id
	)

	if [[ "${#RECORD}" -le 10 ]]; then
		RECORD=$(
			curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
			-H "Authorization: Bearer ${CF_KEY}" \
			-H "Content-Type: application/json" \
			--data '{"type":"A","name":"'${SUB_DOMAIN}'","content":"'${IP}'","proxied":false}' | jq -r .result.id
		)
	else
		RESULT=$(
		curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD}" \
		-H "Authorization: Bearer ${CF_KEY}" \
		-H "Content-Type: application/json" \
		--data '{"type":"A","name":"'${SUB_DOMAIN}'","content":"'${IP}'","proxied":false}'
	)
	fi
		
	if [[ "${#RECORD1}" -le 10 ]]; then
		RECORD2=$(
			curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
			-H "Authorization: Bearer ${CF_KEY}" \
			-H "Content-Type: application/json" \
			--data '{"type":"A","name":"'${NS_DOMAIN}'","content":"'${IP}'","proxied":true}' | jq -r .result.id
		)
	else

	RESULT2=$(
		curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD1}" \
		-H "Authorization: Bearer ${CF_KEY}" \
		-H "Content-Type: application/json" \
		--data '{"type":"A","name":"'${NS_DOMAIN}'","content":"'${IP}'","proxied":true}'
	)	
	fi
echo "Host : $SUB_DOMAIN"
echo "$SUB_DOMAIN" > /root/domain
echo "$NS_DOMAIN" > /root/nsdomain
echo "$SUB_DOMAIN" > /etc/xray/domain
echo "$SUB_DOMAIN" > /etc/v2ray/domain
echo "$SUB_DOMAIN" > /root/scdomain
echo "$SUB_DOMAIN" > /root/xray/scdomain
echo -e "Done Record Domain= $SUB_DOMAIN"
echo -e "Done Record NSDomain= $NS_DOMAIN"
rm -rf cf
sleep 1