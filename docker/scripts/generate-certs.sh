#!/bin/bash

set -e

CERTS_DIR="./docker/infrastructure/certs"
CERT_FILE="$CERTS_DIR/selfsigned.crt"
KEY_FILE="$CERTS_DIR/selfsigned.key"

echo "🔐 Проверка SSL сертификатов..."

mkdir -p "$CERTS_DIR"

if [[ -f "$CERT_FILE" && -f "$KEY_FILE" ]]; then
    echo "✅ SSL сертификаты уже существуют"
    
    if openssl x509 -checkend 86400 -noout -in "$CERT_FILE" >/dev/null 2>&1; then
        echo "✅ Сертификат действителен (срок действия больше 24 часов)"
        
        echo "📋 Информация о сертификате:"
        openssl x509 -in "$CERT_FILE" -text -noout | grep -E "(Subject:|Not Before|Not After)" | sed 's/^/   /'
        
        exit 0
    else
        echo "⚠️  Сертификат истекает в течение 24 часов, пересоздаем..."
        rm -f "$CERT_FILE" "$KEY_FILE"
    fi
else
    echo "📝 SSL сертификаты не найдены, создаем новые..."
fi

echo "🔧 Генерация самоподписанного SSL сертификата..."

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$KEY_FILE" \
    -out "$CERT_FILE" \
    -subj "/CN=localhost/O=LocalDev/C=RU" \
    -addext "subjectAltName=DNS:localhost,DNS:*.localhost,IP:127.0.0.1,IP:::1"

chmod 644 "$KEY_FILE"
chmod 644 "$CERT_FILE"

echo "✅ SSL сертификаты созданы успешно"
echo "📁 Расположение: $CERTS_DIR"
echo "🔑 Приватный ключ: $KEY_FILE"
echo "📜 Сертификат: $CERT_FILE"

echo ""
echo "📋 Информация о созданном сертификате:"
openssl x509 -in "$CERT_FILE" -text -noout | grep -E "(Subject:|Not Before|Not After)" | sed 's/^/   /'