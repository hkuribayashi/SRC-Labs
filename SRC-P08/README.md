# SRC-P08 (Web Application Firewall - WAF com Docker)

Este projeto é uma demonstração reproduzível do funcionamento de um **Web Application Firewall (WAF)** operando na camada de aplicação (Camada 7 do modelo OSI), executado de forma isolada dentro de um contêiner **Docker**. O laboratório permite observar na prática como requisições HTTP legítimas e maliciosas são inspecionadas e filtradas antes de atingirem um servidor web, além de ensinar como auditar os logs do servidor dentro do contêiner.

Este projeto é para alunos da disciplina **SI01033 (Segurança em Redes de Computadores)** do Curso de Sistemas de Informação da Unifesspa, que querem testar ferramentas de defesa de aplicações web para reproduzir os próprios resultados ou criar variações de ataques e regras de bloqueio em ambiente controlado.

> **Aviso Ético:** Todos os testes deste roteiro devem ser executados exclusivamente contra o contêiner local (`localhost` / `127.0.0.1`) configurado no laboratório. Nunca envie payloads de ataque contra servidores públicos ou institucionais.

---

## Arquitetura do Laboratório

Para visualizar o bloqueio em tempo real sem alterar os serviços da máquina hospedeira, o laboratório utiliza a seguinte arquitetura:

1. **Cliente no Hospedeiro (`netcat`):** Envia requisições HTTP puras e payloads simulando ataques (SQL Injection e XSS) para a porta `8080` do computador local.
2. **WAF no Contêiner (`Nginx + ModSecurity` na porta `8080`):** Recebe o tráfego mapeado pelo Docker, atua como proxy reverso e inspeciona cabeçalhos, URLs e parâmetros com base nas regras da **OWASP CRS**.
3. **Aplicação Web Isolada no Contêiner (`Python HTTP Server` na porta `9000`):** Roda internamente apenas em `127.0.0.1:9000` dentro do contêiner (sem porta exposta para fora). Se o WAF bloquear o ataque, a requisição sequer alcança a aplicação.

---

## Ferramentas e Preparação do Ambiente

Instalar o **Docker** e o **netcat** via terminal do Linux (Debian/Ubuntu):

```bash
$ sudo apt update
$ sudo apt install -y docker.io netcat-openbsd
$ sudo systemctl enable --now docker

```

Para executar comandos Docker sem precisar utilizar `sudo`, adicione seu usuário ao grupo `docker`:

```bash
$ sudo usermod -aG docker $USER
$ newgrp docker

```

### 1. Criando os Arquivos do Contêiner

Crie uma pasta dedicada ao projeto e acesse-a:

```bash
$ mkdir -p ~/src-p09-waf && cd ~/src-p09-waf

```

**a) Página da aplicação web protegida (`index.html`):**

```bash
$ cat << 'EOF' > index.html
<!DOCTYPE html>
<html lang="pt-BR">
<head><meta charset="UTF-8"><title>SRC-P09 WAF</title></head>
<body>
  <h1>Aplicacao Web Protegida pelo WAF no Docker</h1>
</body>
</html>
EOF

```

**b) Configuração do Proxy Reverso com WAF (`nginx-waf.conf`):**

```bash
$ cat << 'EOF' > nginx-waf.conf
server {
    listen 8080;
    server_name localhost;

    modsecurity on;
    modsecurity_rules_file /etc/modsecurity/modsecurity.conf;

    location / {
        proxy_pass http://127.0.0.1:9000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

```

**c) Script de inicialização dos serviços no contêiner (`entrypoint.sh`):**

```bash
$ cat << 'EOF' > entrypoint.sh
#!/bin/bash
set -e

# Inicia a aplicacao web interna na porta 9000 (isolada dentro do container)
python3 -m http.server 9000 --bind 127.0.0.1 --directory /var/www/app &

# Inicia o Nginx com o WAF ativo em primeiro plano
exec nginx -g "daemon off;"
EOF

```

**d) Receita da imagem (`Dockerfile`):**

*(Nota: Como o Debian instala o motor ModSecurity v3, o arquivo `/etc/modsecurity/modsecurity.conf` é gerado diretamente durante o build com o modo de bloqueio `SecRuleEngine On` ativado).*

```bash
$ cat << 'EOF' > Dockerfile
FROM debian:bookworm-slim

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

# 3. Configura o Nginx e copia os arquivos da aplicacao
RUN rm -f /etc/nginx/sites-enabled/default && mkdir -p /var/www/app
COPY nginx-waf.conf /etc/nginx/conf.d/waf.conf
COPY index.html /var/www/app/index.html
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 4. Valida a sintaxe do Nginx e das regras OWASP
RUN nginx -t

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
EOF

```

### 2. Construindo e Executando o Contêiner

Construa a imagem Docker chamada `src-p09-waf:1.0`:

```bash
$ docker build -t src-p09-waf:1.0 .

```

Inicie o contêiner em segundo plano (`-d`), mapeando a porta `8080` do hospedeiro para a porta `8080` do contêiner:

```bash
$ docker run -d --name lab-waf -p 8080:8080 src-p09-waf:1.0

```

Confirme que o contêiner está em execução:

```bash
$ docker ps

```

---

## Executando o Experimento

Para acompanhar o comportamento do WAF em tempo real, abra **dois terminais** no sistema hospedeiro.

### Terminal 1: Monitorando os Logs do Nginx dentro do Contêiner

Execute o comando `docker exec` com `tail -f` para assistir ao vivo aos arquivos de acesso e de erro/bloqueio do Nginx que ficam armazenados dentro do sistema de arquivos do contêiner:

```bash
$ docker exec -it lab-waf tail -f /var/log/nginx/access.log /var/log/nginx/error.log

```

Mantenha este terminal visível durante todos os testes abaixo.

---

### Terminal 2: Testando Requisições via `netcat`

#### Cenário A: Requisição HTTP Legítima (Tráfego Permitido)

Conecte-se à porta `8080` (mapeada para o WAF no contêiner) usando o `netcat` e envie uma requisição comum:

```bash
$ nc -C localhost 8080
GET / HTTP/1.1
Host: localhost
Connection: close

```

*(Pressione **ENTER** duas vezes após `Connection: close` para finalizar a requisição).*

**Resultado esperado:**

* No **Terminal 2**, o WAF encaminha o pedido ao backend interno e devolve `HTTP/1.1 200 OK` junto com o HTML da página.
* No **Terminal 1**, o log `/var/log/nginx/access.log` exibe a entrada `"GET / HTTP/1.1" 200`.

---

#### Cenário B: Simulando um Ataque de SQL Injection (Bloqueio pelo WAF)

Envie uma requisição contendo um payload clássico de **SQL Injection** na URL (`?id=1' OR '1'='1`):

```bash
$ nc -C localhost 8080
GET /?id=1'%20OR%20'1'='1 HTTP/1.1
Host: localhost
Connection: close

```

*(Pressione **ENTER** duas vezes ao final).*

**Resultado esperado:**

* No **Terminal 2**, o ModSecurity identifica o padrão malicioso e interrompe a conexão imediatamente, respondendo com **`HTTP/1.1 403 Forbidden`**.
* No **Terminal 1**, o `/var/log/nginx/error.log` exibe o alerta `ModSecurity: Access denied with code 403` antes mesmo que a requisição chegue ao servidor Python na porta `9000`.

---

#### Cenário C: Simulando Cross-Site Scripting (XSS) e Ferramentas Automatizadas

Repita o procedimento testando outros dois vetores comuns de ataque web:

1. **Injeção de script malicioso (XSS) via parâmetro de busca:**
```bash
$ nc -C localhost 8080
GET /?busca=<script>alert('XSS')</script> HTTP/1.1
Host: localhost
Connection: close

```


*(Resposta esperada: `HTTP/1.1 403 Forbidden`)*
2. **Varredura por scanner de vulnerabilidades (cabeçalho `User-Agent` malicioso):**
```bash
$ nc -C localhost 8080
GET / HTTP/1.1
Host: localhost
User-Agent: sqlmap/1.7
Connection: close

```


*(Resposta esperada: `HTTP/1.1 403 Forbidden`)*

---

## Como Acessar e Auditar os Logs do Nginx no Contêiner

Como o Nginx e o ModSecurity executam isolados dentro do contêiner `lab-waf`, os arquivos de log não ficam na pasta `/var/log` da máquina hospedeira, mas sim dentro do contêiner. Utilize o comando `docker exec` para consultá-los:

### 1. Filtrar bloqueios e regras OWASP no log de erros (`/var/log/nginx/error.log`)

Para listar os últimos bloqueios realizados pelo WAF e identificar os códigos das regras disparadas:

```bash
$ docker exec lab-waf grep -E "ModSecurity|403" /var/log/nginx/error.log | tail -n 10

```

Na saída, observe os identificadores gerados pela OWASP CRS:

* **`[id "942100"]`**: Assinatura que detectou tentativa de *SQL Injection*.
* **`[id "941100"]`**: Assinatura que detectou tentativa de *Cross-Site Scripting (XSS)*.
* **`[id "913100"]`**: Assinatura que identificou o *User-Agent* de scanner automatizado.
* **`[severity "CRITICAL"]`**: Nível de criticidade atribuído à anomalia.

### 2. Consultar o histórico de acessos (`/var/log/nginx/access.log`)

Para visualizar todas as requisições recebidas pelo proxy reverso e seus respectivos códigos de status HTTP (`200` para permitidas e `403` para bloqueadas):

```bash
$ docker exec lab-waf cat /var/log/nginx/access.log

```

### 3. Inspecionar a auditoria forense completa (`/var/log/nginx/modsec_audit.log`)

O ModSecurity grava um relatório detalhado contendo os cabeçalhos completos, o payload enviado pelo atacante e a justificativa técnica de cada bloqueio:

```bash
$ docker exec lab-waf tail -n 35 /var/log/nginx/modsec_audit.log

```

### 4. Abrir um terminal interativo dentro do contêiner (opcional)

Caso queira navegar diretamente pelos diretórios de configuração e logs do Nginx dentro do contêiner:

```bash
$ docker exec -it lab-waf bash
root@<id_container>:/# ls -lh /var/log/nginx/
root@<id_container>:/# exit

```

Para encerrar e remover o contêiner ao término da prática:

```bash
$ docker stop lab-waf && docker rm lab-waf

```

---

## Sugestões de Variações para o Aluno

1. **Injeção de Regra Personalizada via Volume Docker:** Crie uma regra própria na máquina hospedeira bloqueando a palavra `secreto` e injete-a diretamente no contêiner sem precisar reconstruir a imagem:
```bash
$ echo 'SecRule ARGS "@contains secreto" "id:10001,phase:2,deny,status:403,msg:\x27Palavra proibida bloqueada\x27"' > regra-aluno.conf
$ docker stop lab-waf && docker rm lab-waf
$ docker run -d --name lab-waf -p 8080:8080 -v $(pwd)/regra-aluno.conf:/usr/share/modsecurity-crs/rules/REQUEST-999-ALUNO.conf src-p09-waf:1.0

```


Em seguida, teste `GET /?arquivo=secreto HTTP/1.1` via `netcat` e verifique o bloqueio `403 Forbidden` nos logs do contêiner.
2. **Comparação Modo IDS vs. IPS (`DetectionOnly` vs. `On`):** Altere `SecRuleEngine On` para `SecRuleEngine DetectionOnly` no `Dockerfile`, reconstrua a imagem e repita o Cenário B. Observe no `/var/log/nginx/access.log` e `/var/log/nginx/error.log` do contêiner que o ataque passa a retornar `200 OK`, mas continua gerando alertas de detecção.

## Conclusão

O objetivo deste projeto é demonstrar, de forma prática, isolada e reproduzível com Docker, a diferença entre um firewall tradicional de rede (que apenas libera ou bloqueia o tráfego na porta `8080`) e um **Web Application Firewall (WAF)**, que inspeciona o conteúdo semântico do protocolo HTTP na Camada 7 para mitigar ataques diretamente contra aplicações web.
