#!/bin/sh
# Works out the current network every minute, since the Pi moves between networks:
#   - router (default gateway) and first ISP hop -> /targets/ping.json (Prometheus file_sd for blackbox)
#   - public IP, ISP, extra NAT, connected-since  -> /textfile/netinfo.prom (node_exporter textfile)
# ponytail: ipinfo.io only every 5th loop to stay inside its free limit; add a token if that ever bites.

PRIVATE='^(10\.|100\.(6[4-9]|[7-9][0-9]|1[01][0-9]|12[0-7])\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.)'
n=0; key=""; since=$(date +%s); ip_json=""

while true; do
  gw=$(ip -4 route show default | awk '{print $3; exit}')
  hops=$(traceroute -n -q 1 -w 1 -m 6 1.1.1.1 2>/dev/null | awk 'NR>0 && $2 ~ /^[0-9.]+$/ {print $2}')
  isp_hop=$(echo "$hops" | grep -v "^$gw$" | head -1)
  # a private address after the router, before the first public hop = CGNAT or double NAT
  extra_nat=0
  for h in $(echo "$hops" | grep -v "^$gw$"); do
    echo "$h" | grep -Eq "$PRIVATE" && extra_nat=1 || break
  done

  # keep the last good answer through outages
  [ $((n % 5)) -eq 0 ] && { j=$(curl -s -m 5 https://ipinfo.io/json); echo "$j" | grep -q '"ip"' && ip_json=$j; }
  n=$((n + 1))
  field() { echo "$ip_json" | sed -n "s/.*\"$1\": *\"\([^\"]*\)\".*/\1/p" | tr -d '\\"'; }
  pub=$(field ip); isp=$(field org); city=$(field city)

  # new router or new ISP = new network; public IP alone churns on CGNAT
  [ "$gw|$isp" != "$key" ] && { key="$gw|$isp"; since=$(date +%s); }

  {
    echo '['
    [ -n "$gw" ] && printf '{"targets":["%s"],"labels":{"role":"router"}}' "$gw"
    [ -n "$gw" ] && [ -n "$isp_hop" ] && printf ','
    [ -n "$isp_hop" ] && printf '{"targets":["%s"],"labels":{"role":"isp"}}' "$isp_hop"
    echo ']'
  } > /targets/ping.json.tmp && mv /targets/ping.json.tmp /targets/ping.json

  cat > /textfile/netinfo.prom.tmp <<EOF
netinfo_info{gateway="$gw",isp_hop="$isp_hop",public_ip="$pub",isp="$isp",city="$city"} 1
netinfo_extra_nat $extra_nat
netinfo_connected_since_seconds $since
EOF
  mv /textfile/netinfo.prom.tmp /textfile/netinfo.prom
  sleep 60
done
