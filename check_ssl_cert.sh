#!/bin/bash
#inspired by a post at
#https://www.cyberciti.biz/faq/find-check-tls-ssl-certificate-expiry-date-from-linux-unix/

DOMAIN="$1"
FLAG="$2"
SETTINGS_FILE="$(dirname "$0")/settings.json"

if [ ! -f "$SETTINGS_FILE" ]; then
  echo "Settings file not found at $SETTINGS_FILE"
  exit 1
fi

CERTS_ROOT=$(jq -r '.certs_root' "$SETTINGS_FILE")
if [ -z "$CERTS_ROOT" ] || [ "$CERTS_ROOT" == "null" ]; then
  echo "certs_root not set in $SETTINGS_FILE"
  exit 1
fi

CERT_PATH="$CERTS_ROOT/$DOMAIN/domain.cert.pem"

if [ ! -f "$CERT_PATH" ]; then
  echo "Certificate not found for $DOMAIN at $CERT_PATH"
  exit 1
fi

# Get the notAfter date from the certificate
END_DATE=$(openssl x509 -enddate -noout -in "$CERT_PATH" | cut -d= -f2)
END_DATE_EPOCH=$(date -d "$END_DATE" +%s)
NOW_EPOCH=$(date +%s)
SEVEN_DAYS=$((7 * 24 * 60 * 60))
DIFF=$((END_DATE_EPOCH - NOW_EPOCH))

if [ "$DIFF" -le "$SEVEN_DAYS" ]; then
  if [ "$FLAG" == "--bool" ]; then
    echo "true"
  else
    echo "Certificate for $DOMAIN expires within 7 days: $END_DATE"
  fi
  exit 2
else
  if [ "$FLAG" == "--bool" ]; then
    echo "false"
  else
    echo "Certificate for $DOMAIN is valid until: $END_DATE"
  fi
  exit 0
fi