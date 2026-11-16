FROM debian:bookworm-slim

# Evita perguntas interativas durante a instalacao de pacotes
ENV DEBIAN_FRONTEND=noninteractive

# 1. Instala Nginx, modulo ModSecurity (v3), regras OWASP CRS e Python3
RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    libnginx-mod-http-modsecurity \
    modsecurity-crs \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# 2. Cria a configuracao do ModSecurity v3 em modo de bloqueio e carrega as regras OWASP
RUN mkdir -p /etc/modsecurity && printf '%s\n' \
    'SecRuleEngine On' \
    'SecRequestBodyAccess On' \
    'SecRequestBodyLimit 13107200' \
    'SecRequestBodyNoFilesLimit 131072' \
    'SecRequestBodyLimitAction Reject' \
    'SecResponseBodyAccess On' \
    'SecResponseBodyMimeType text/plain text/html text/xml' \
    'SecResponseBodyLimit 524288' \
    'SecResponseBodyLimitAction ProcessPartial' \
    'SecTmpDir /tmp/' \
    'SecDataDir /tmp/' \
    'SecAuditEngine RelevantOnly' \
    'SecAuditLogRelevantStatus "^(?:5|4(?!04))"' \
    'SecAuditLogParts ABIJDEFHZ' \
    'SecAuditLogType Serial' \
    'SecAuditLog /var/log/nginx/modsec_audit.log' \
    'SecArgumentSeparator &' \
    'SecCookieFormat 0' \
    'Include /etc/modsecurity/crs/crs-setup.conf' \
    'Include /usr/share/modsecurity-crs/rules/*.conf' \
    > /etc/modsecurity/modsecurity.conf

# 3. Remove o site padrao do Nginx e copia a configuracao do laboratorio
RUN rm -f /etc/nginx/sites-enabled/default && mkdir -p /var/www/app
COPY nginx-waf.conf /etc/nginx/conf.d/waf.conf
COPY index.html /var/www/app/index.html
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 4. Valida a sintaxe do Nginx e das regras OWASP durante o build
RUN nginx -t

# Expoe apenas a porta do WAF (a porta 9000 permanece isolada dentro do container)
EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]