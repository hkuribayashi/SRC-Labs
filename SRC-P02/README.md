# Laboratório de Port Scanning com Nmap

Este projeto é uma demonstração reproduzível dos conceitos de **Port Scanning**, utilizando o software **Nmap (Network Mapper)**.

Este laboratório foi desenvolvido para os alunos da disciplina **SI01033 — Segurança em Redes de Computadores**, do Curso de Sistemas de Informação da **Unifesspa**, permitindo experimentar técnicas de reconhecimento de serviços de rede, identificação de portas TCP e UDP e utilização do **Nmap Scripting Engine (NSE)** para verificações relacionadas a vulnerabilidades.

> **Atenção:** os testes deste laboratório devem ser realizados somente contra máquinas, redes e aplicações sobre as quais você tenha autorização para realizar testes. Recomenda-se utilizar uma máquina virtual ou outro host disponibilizado especificamente para o laboratório.

---

## Objetivos

Ao final deste laboratório, o discente deverá ser capaz de:

* compreender o conceito de **Port Scanning**;
* diferenciar portas **TCP** e **UDP**;
* utilizar o Nmap para identificar portas abertas;
* interpretar os estados `open`, `closed` e `filtered`;
* identificar serviços associados às portas;
* obter informações sobre versões de serviços;
* utilizar o **Nmap Scripting Engine (NSE)**;
* interpretar resultados de verificações relacionadas a vulnerabilidades;
* compreender as limitações de ferramentas automatizadas de identificação de vulnerabilidades.

---

## Pré-requisitos

Para realizar o laboratório, será necessário:

* Linux, macOS ou Windows;
* Nmap instalado;
* uma máquina-alvo autorizada para os testes.

### Instalação no Ubuntu/Debian

```bash
sudo apt update
sudo apt install nmap
```

Verifique a instalação:

```bash
nmap --version
```

Uma instalação funcional deverá apresentar informações sobre a versão do Nmap e da biblioteca Nmap Scripting Engine.

---

# Exemplo 01 — TCP Port Scanning

Neste primeiro experimento, vamos realizar uma varredura das portas TCP de um host.

Utilize:

```bash
nmap -sT ENDERECO_IP
```

Por exemplo:

```bash
nmap -sT 192.168.56.101
```

O parâmetro `-sT` solicita um **TCP Connect Scan**.

Nesse tipo de varredura, o Nmap tenta estabelecer uma conexão TCP com as portas examinadas.

### O que observar?

Na saída do Nmap, procure uma tabela semelhante a:

```text
PORT     STATE    SERVICE
22/tcp   open     ssh
80/tcp   open     http
443/tcp  closed   https
```

Observe principalmente:

* **PORT** — número e protocolo da porta;
* **STATE** — estado identificado pelo Nmap;
* **SERVICE** — serviço normalmente associado à porta.

### Atividade

1. Execute o scan contra o host disponibilizado pelo professor.
2. Liste as portas TCP identificadas.
3. Identifique quais portas estão `open`.
4. Para cada porta aberta, indique o serviço associado pelo Nmap.
5. Verifique se os serviços realmente estão em execução no host-alvo.

---

# Exemplo 02 — UDP Port Scanning

Agora vamos investigar portas UDP.

Execute:

```bash
nmap -sU ENDERECO_IP
```

Por exemplo:

```bash
nmap -sU 192.168.56.101
```

O parâmetro `-sU` solicita um **UDP Scan**.

Uma diferença importante em relação ao TCP é que o UDP não possui o mecanismo de estabelecimento de conexão utilizado pelo TCP. Por isso, a identificação do estado das portas pode ser mais lenta e apresentar estados como:

```text
open
open|filtered
closed
```

### Atividade

1. Execute o scan UDP.
2. Identifique as portas classificadas como `open`.
3. Compare os resultados com o TCP Scan.
4. Existem serviços identificados em UDP que não aparecem na varredura TCP?
5. Existem portas classificadas como `open|filtered`?
6. Por que a determinação do estado de uma porta UDP pode ser mais difícil?

---

# Exemplo 03 — Identificação de Serviços

Podemos solicitar ao Nmap uma tentativa de identificação mais detalhada dos serviços executados nas portas abertas.

Utilize:

```bash
nmap -sV ENDERECO_IP
```

Por exemplo:

```bash
nmap -sV 192.168.56.101
```

O parâmetro `-sV` ativa a **detecção de versão dos serviços**.

Uma saída poderá apresentar algo semelhante a:

```text
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 9.x
80/tcp open  http    Apache httpd 2.4.x
```

### Atividade

Compare:

```bash
nmap -sT ENDERECO_IP
```

com:

```bash
nmap -sV ENDERECO_IP
```

Responda:

1. Qual informação adicional foi obtida com `-sV`?
2. Por que identificar a versão de um serviço pode ser relevante em Segurança da Informação?
3. A identificação apresentada pelo Nmap deve ser considerada uma prova definitiva da versão instalada? Justifique.

---

# Exemplo 04 — Detecção de Vulnerabilidades com NSE

O Nmap possui o **Nmap Scripting Engine (NSE)**, que permite executar scripts especializados.

Para executar os scripts da categoria `vuln`:

```bash
nmap --script vuln ENDERECO_IP
```

Por exemplo:

```bash
nmap --script vuln 192.168.56.101
```

A categoria `vuln` contém scripts destinados a verificar determinadas condições associadas a vulnerabilidades conhecidas.

### Atenção

Um resultado indicando uma possível vulnerabilidade não deve ser interpretado automaticamente como uma confirmação definitiva de que o sistema pode ser explorado.

Um script NSE pode produzir **indícios** ou realizar verificações específicas. A validação de uma vulnerabilidade normalmente exige análise adicional.

Da mesma forma, a ausência de um alerta **não significa que o host esteja livre de vulnerabilidades**.

### Atividade

Execute:

```bash
nmap --script vuln ENDERECO_IP
```

Registre:

1. quais scripts foram executados;
2. quais serviços foram analisados;
3. quais resultados foram apresentados;
4. quais vulnerabilidades ou possíveis vulnerabilidades foram identificadas;
5. quais evidências foram apresentadas pelo Nmap;
6. quais resultados exigiriam validação adicional.

---

# Exemplo 05 — Construindo um Perfil do Host

Agora vamos combinar algumas das técnicas anteriores.

Execute:

```bash
nmap -sT -sV ENDERECO_IP
```

Depois:

```bash
nmap -sU -sV ENDERECO_IP
```

Compare os resultados.

A partir dessas informações, construa uma tabela semelhante à seguinte:

| Protocolo | Porta | Estado | Serviço | Versão |
| --------- | ----: | ------ | ------- | ------ |
| TCP       |    22 | open   | SSH     | ...    |
| TCP       |    80 | open   | HTTP    | ...    |
| UDP       |    53 | open   | DNS     | ...    |

O objetivo é construir um **perfil da superfície de exposição do host**.

---

# Desafio — Reconhecimento de um Servidor de Laboratório

O professor disponibilizará um host destinado exclusivamente à atividade.

O discente deverá realizar um processo de reconhecimento utilizando:

```bash
nmap -sT ENDERECO_IP
```

```bash
nmap -sU ENDERECO_IP
```

```bash
nmap -sV ENDERECO_IP
```

e:

```bash
nmap --script vuln ENDERECO_IP
```

# Salvando os Resultados

Para tornar o experimento reproduzível, recomenda-se salvar a saída dos comandos em arquivos.

Por exemplo:

```bash
nmap -sT -sV ENDERECO_IP -oN resultado-tcp.txt
```

Para UDP:

```bash
nmap -sU -sV ENDERECO_IP -oN resultado-udp.txt
```

Para os scripts de vulnerabilidade:

```bash
nmap --script vuln ENDERECO_IP -oN resultado-vulnerabilidades.txt
```

Dessa forma, os resultados podem ser posteriormente analisados e comparados.

Uma possível organização dos arquivos é:

```text
resultados/
├── resultado-tcp.txt
├── resultado-udp.txt
└── resultado-vulnerabilidades.txt
```

# Conclusão

O objetivo deste laboratório é permitir que o discente compreenda, de forma prática, o processo de **reconhecimento de serviços de rede por meio de Port Scanning**.

A atividade permite experimentar as diferenças entre **TCP e UDP**, identificar serviços e versões e conhecer o uso do **Nmap Scripting Engine** para verificações relacionadas a vulnerabilidades.

