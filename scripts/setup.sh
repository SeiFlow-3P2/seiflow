#!/bin/bash

if [ ! -f ".env" ]; then
    cp .env.example .env
    echo "Created .env file from .env.example"
fi

mkdir -p data/{auth_service,payment_service,board_service,calendar_service}/{postgres,redis,mongo}
echo "Created data directories"

git submodule update --init --recursive
echo "Initialized and updated submodules"

echo "Setup completed. You can now run: docker-compose --profile all up -d"