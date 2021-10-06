#!/bin/bash
cat <<'EOF' | docker-compose -f - up -d
version: "3.5"
services:
  whoami:
    image: containous/whoami
    restart: always
    ports:
      - "80:80"
EOF
exit 0