CERTS_DIR="./infrastructure/certs"

mkdir -p "$CERTS_DIR"

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout "$CERTS_DIR/selfsigned.key" \
-out "$CERTS_DIR/selfsigned.crt" \
-subj "/CN=localhost/O=LocalDev/C=RU"
  
chmod 644 "$CERTS_DIR/selfsigned.key"
chmod 644 "$CERTS_DIR/selfsigned.crt"