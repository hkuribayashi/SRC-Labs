#!/bin/bash
set -e

# Inicia a aplicacao web de teste na porta 9000 (apenas localhost interno)
python3 -m http.server 9000 --bind 127.0.0.1 --directory /var/www/app &

# Inicia o Nginx com WAF em primeiro plano
exec nginx -g "daemon off;"