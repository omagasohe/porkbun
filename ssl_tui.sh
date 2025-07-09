#!/bin/bash

SETTINGS_FILE="$(dirname "$0")/settings.json"
CHECK_CERT_SCRIPT="$(dirname "$0")/ssl_key_expire.sh"

CERTS_ROOT=$(jq -r '.certs_root' "$SETTINGS_FILE")
if [ -z "$CERTS_ROOT" ] || [ "$CERTS_ROOT" == "null" ]; then
  echo "certs_root not set in $SETTINGS_FILE"
  exit 1
fi

# Get Porkbun API response
if [ ! -f "./apikey.json" ]; then
  echo "Missing apikey.json in current directory."
  exit 2
fi

API_KEY=$(jq -r '.apikey' ./apikey.json)
SECRET_KEY=$(jq -r '.secretapikey' ./apikey.json)

if [ -z "$API_KEY" ] || [ -z "$SECRET_KEY" ]; then
  echo "API key or secret key not found in apikey.json"
  exit 1
fi


RESPONSE=$(curl -s -X POST "https://api.porkbun.com/api/json/v3/domain/listAll" \
  -H "Content-Type: application/json" \
  -d "{\"apikey\":\"$API_KEY\",\"secretapikey\":\"$SECRET_KEY\",\"start\":\"0\",\"includelabels\":\"yes\"}")

MISSING_CERTS=0
EXPIRED_CERTS=0
MISSING_DOMAINS=""
UPDAGE_DOMAINS=""
CSV_OUT="Domain,Has Certs, Expiring"$'\n'

for DOMAIN in $(echo "$RESPONSE" | jq -r '.domains[].domain'); do
  CERT_PATH="$CERTS_ROOT/$DOMAIN/domain.cert.pem"
  if [ -f "$CERT_PATH" ]; then
    CERT_EXISTS="yes"
    EXPIRES=$("$CHECK_CERT_SCRIPT" "$DOMAIN" --bool)
    if [ "$EXPIRES" == "true" ]; then
      EXPIRED_CERTS=$((EXPIRED_CERTS+1))
      MISSING_DOMAINS+=" $DOMAIN"
    fi
  else
    CERT_EXISTS="no"
    EXPIRES="-"
    MISSING_CERTS=$((MISSING_CERTS+1))
    #echo "No certs found for $DOMAIN ($MISSING_CERTS total)"
    MISSING_DOMAINS+=" $DOMAIN"
  fi
  CSV_OUT+="$DOMAIN,$CERT_EXISTS,$EXPIRES"$'\n'
done

echo "$CSV_OUT" | gum table -p

echo "Missing certs: $MISSING_CERTS"
echo "Certs expiring/expired: $EXPIRED_CERTS"

if [ "$MISSING_CERTS" -gt 0 ]; then
  echo "Would you like to get certs for:"
  UPDAGE_DOMAINS=$(gum choose --no-limit $MISSING_DOMAINS)
    if [ -n "$UPDAGE_DOMAINS" ]; then
        echo "You chose to add missing certs for: $UPDAGE_DOMAINS"
        for DOMAIN in $UPDAGE_DOMAINS; do
        #mkdir -p "$CERTS_ROOT/$DOMAIN"
        ./ssl_pull_keys.sh "$DOMAIN"
        echo "Getting certs for $DOMAIN..."
        done
    else
        echo "No certs will be added."
    fi
fi