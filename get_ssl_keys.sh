#!/bin/bash
if [ -z "$1" ]; then
  echo "Usage: $0 <domain>"
  exit 1
fi

if [ ! -f "./apikey.json" ]; then
  echo "Missing apikey.json in current directory."
  exit 2
fi

API_KEY=$(jq -r '.apikey' ./apikey.json)
SECRET_KEY=$(jq -r '.secretapikey' ./apikey.json)

if [ -z "$1" ]; then
  echo "Usage: $0 <domain>"
  exit 1
fi

DOMAIN="$1"

OUTDIR="$HOME/ssl_keys/$DOMAIN"

mkdir -p "$OUTDIR/"

RESPONSE=$(curl -s -X POST "https://api.porkbun.com/api/json/v3/ssl/retrieve/$DOMAIN" \
  -H "Content-Type: application/json" \
  -d "{\"apikey\":\"$API_KEY\",\"secretapikey\":\"$SECRET_KEY\"}")

echo "API response:"
echo "$RESPONSE"

if echo "$RESPONSE" | jq -e .status >/dev/null 2>&1; then
  STATUS=$(echo "$RESPONSE" | jq -r .status)
  if [ "$STATUS" = "SUCCESS" ]; then
    echo "$RESPONSE" | jq -r '.publickey' > "$OUTDIR/public.key.pem"
    echo "$RESPONSE" | jq -r '.certificatechain' > "$OUTDIR/domain.cert.pem"
    echo "$RESPONSE" | jq -r '.privatekey' > "$OUTDIR/private.key.pem"
    echo "Saved certificate, CA bundle, and private key to $OUTDIR"
  else
    echo "API error: $STATUS"
    echo "$RESPONSE"
  fi
else
  echo "Invalid JSON response from API:"
  echo "$RESPONSE"
fi