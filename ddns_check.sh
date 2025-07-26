if [ ! -f "./apikey.json" ]; then
  echo "Missing apikey.json in current directory."
  exit 2
fi

API_KEY=$(jq -r '.apikey' ./apikey.json)
SECRET_KEY=$(jq -r '.secretapikey' ./apikey.json)
DOMAIN="$1"
SUBDOMAIN="$2"
# curl -w '\n' https://ipecho.net/plain
# curl -w '\n' v4.ident.me
# curl ipv4.icanhazip.com
# curl https://checkip.amazonaws.com

MY_IP=$(curl -s https://checkip.amazonaws.com | tr -d '\n')

RESPONSE=$(curl -s -X POST "https://api.porkbun.com/api/json/v3/dns/retrieveByNameType/$DOMAIN/A/$SUBDOMAIN" \
  -H "Content-Type: application/json" \
  -d "{\"apikey\":\"$API_KEY\",\"secretapikey\":\"$SECRET_KEY\"}")
RESPONSE_IP=$(echo "$RESPONSE" | jq -r '.records[0].content')
if [ "$RESPONSE_IP" == "null" ]; then
  echo "No A record found for $SUBDOMAIN.$DOMAIN"
  exit 1
fi
if [ "$RESPONSE_IP" == "$MY_IP" ]; then
  echo "A record for $SUBDOMAIN.$DOMAIN is correctly set to $MY_IP"
else
  echo "A record for $SUBDOMAIN.$DOMAIN is set to $RESPONSE_IP, but should be $MY_IP"
  # Optionally, you can update the A record here
  # curl -s -X POST "https://api.porkbun.com/api/json/v3/dns/editRecord" \
  #   -H "Content-Type: application/json" \
  #   -d "{\"apikey\":\"$API_KEY\",\"secretapikey\":\"$SECRET_KEY\",\"domain\":\"$DOMAIN\",\"name\":\"$SUBDOMAIN\",\"type\":\"A\",\"content\":\"$MY_IP\"}"
fi
RESPONSE=$(curl -s -X POST "https://api.porkbun.com/api/json/v3/dns/retrieveByNameType/$DOMAIN/A/*.$SUBDOMAIN" \
  -H "Content-Type: application/json" \
  -d "{\"apikey\":\"$API_KEY\",\"secretapikey\":\"$SECRET_KEY\"}")
RESPONSE_IP=$(echo "$RESPONSE" | jq -r '.records[0].content')
if [ "$RESPONSE_IP" == "null" ]; then
  echo "No A record found for *.$SUBDOMAIN.$DOMAIN"
  exit 1
fi

if [ "$RESPONSE_IP" == "$MY_IP" ]; then
  echo "A record for *.$SUBDOMAIN.$DOMAIN is correctly set to $MY_IP"
else
  echo "A record for *.$SUBDOMAIN.$DOMAIN is set to $RESPONSE_IP, but should be $MY_IP"
  # Optionally, you can update the A record here
  # curl -s -X POST "https://api.porkbun.com/api/json/v3/dns/editRecord" \
  #   -H "Content-Type: application/json" \
  #   -d "{\"apikey\":\"$API_KEY\",\"secretapikey\":\"$SECRET_KEY\",\"domain\":\"$DOMAIN\",\"name\":\"$SUBDOMAIN\",\"type\":\"A\",\"content\":\"$MY_IP\"}"
fi