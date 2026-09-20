# Laboratório de Captura de Tráfego de Rede com tcpdump

Este projeto é uma demonstração reproduzível dos conceitos de **captura e análise de tráfego de rede**, utilizando a ferramenta `tcpdump` em sistemas GNU/Linux.

O `tcpdump` é uma ferramenta de linha de comando utilizada para capturar e analisar pacotes que trafegam por uma interface de rede. Neste laboratório, serão explorados conceitos relacionados a protocolos de rede, endereçamento IP, ARP, ICMP, TCP, UDP, DNS e HTTP.

Este projeto é para alunos da disciplina **SI01033 (Segurança em Redes de Computadores)** do Curso de Sistemas de Informação da **Unifesspa**, que querem experimentar ferramentas de análise de tráfego em um ambiente controlado e reproduzir os experimentos realizados em sala de aula.

> **Importante:** os experimentos devem ser realizados exclusivamente em redes, equipamentos e dispositivos autorizados para fins acadêmicos. Recomenda-se utilizar um **Access Point (AP) dedicado ao laboratório**, sem conexão com a rede institucional ou com a Internet.

## Preparação do laboratório

Para realizar os experimentos, será necessário:

* Um computador com GNU/Linux;
* Uma interface de rede, preferencialmente sem fio;
* O programa `tcpdump`;
* Um Access Point (AP) destinado exclusivamente ao laboratório;
* Pelo menos dois computadores conectados ao AP;
* Permissão administrativa (`sudo`) para realizar a captura de pacotes.

Em distribuições baseadas em Debian/Ubuntu, o `tcpdump` pode ser instalado com:

```bash
sudo apt update
sudo apt install tcpdump
```

Para verificar a instalação:

```bash
tcpdump --version
```

## Exemplo 01 — Identificando as interfaces de rede

Começamos identificando as interfaces de rede disponíveis no computador.

Execute:

```bash
ip link
```

Para identificar especificamente as interfaces sem fio:

```bash
iw dev
```

Identifique qual interface está conectada ao AP do laboratório.

Por exemplo:

```text
wlan0
```

ou:

```text
wlp2s0
```

> O nome da interface pode variar de acordo com o sistema operacional, hardware e configuração do computador.

## Exemplo 02 — Primeira captura

Agora vamos realizar uma captura simples utilizando o `tcpdump`.

Substitua `wlan0` pelo nome da interface utilizada no seu computador:

```bash
sudo tcpdump -i wlan0
```

Enquanto a captura estiver sendo realizada, gere tráfego a partir de outro computador conectado ao mesmo AP.

Por exemplo:

```bash
ping 192.168.50.1
```

Observe os pacotes apresentados pelo `tcpdump`.

Para interromper a captura:

```text
Ctrl+C
```

### O que deve ser observado?

Identifique:

1. O endereço IP de origem;
2. O endereço IP de destino;
3. O protocolo utilizado;
4. O sentido da comunicação;
5. A quantidade de pacotes capturados.

## Exemplo 03 — Capturando somente ICMP

O protocolo ICMP pode ser observado utilizando um filtro:

```bash
sudo tcpdump -i wlan0 icmp
```

Em outro computador, execute:

```bash
ping 192.168.50.1
```

Observe a diferença entre a captura sem filtro e a captura utilizando:

```text
icmp
```

### Desafio

Explique a diferença entre:

```text
Echo Request
```

e:

```text
Echo Reply
```

## Exemplo 04 — Capturando ARP

O protocolo ARP é utilizado para descobrir o endereço MAC associado a um endereço IPv4 na rede local.

Execute:

```bash
sudo tcpdump -i wlan0 -nn arp
```

Depois, gere tráfego para um computador da rede.

Por exemplo:

```bash
ping 192.168.50.103
```

Observe mensagens semelhantes a:

```text
ARP, Request who-has ...
ARP, Reply ...
```

### O que deve ser identificado?

1. Qual endereço IP está sendo procurado?
2. Qual dispositivo realizou a solicitação?
3. Qual endereço MAC respondeu?
4. Qual é a relação entre o endereço IPv4 e o endereço MAC?

## Exemplo 05 — Capturando tráfego TCP

Neste experimento será utilizada uma aplicação HTTP simples.

Em um computador, execute:

```bash
python3 -m http.server 8000
```

Descubra o endereço IP desse computador:

```bash
ip addr
```

Em outro computador, acesse:

```text
http://IP_DO_SERVIDOR:8000
```

No computador utilizado para captura, execute:

```bash
sudo tcpdump -i wlan0 -nn 'tcp port 8000'
```

Observe o estabelecimento da conexão TCP.

Os alunos deverão identificar:

```text
SYN
SYN/ACK
ACK
```

### Desafio

Explique a função de cada uma dessas três mensagens no estabelecimento de uma conexão TCP.

## Exemplo 06 — Capturando DNS

Para observar consultas DNS:

```bash
sudo tcpdump -i wlan0 -nn port 53
```

Em outro terminal, execute:

```bash
nslookup exemplo.com
```

ou:

```bash
dig exemplo.com
```

Observe:

* endereço IP de origem;
* endereço IP de destino;
* porta utilizada;
* protocolo de transporte;
* consulta DNS;
* resposta DNS.

## Exemplo 07 — Capturando somente um determinado computador

Podemos filtrar o tráfego de um determinado endereço IP.

Por exemplo:

```bash
sudo tcpdump -i wlan0 -nn host 192.168.50.102
```

Também podemos especificar a origem:

```bash
sudo tcpdump -i wlan0 -nn src host 192.168.50.102
```

ou o destino:

```bash
sudo tcpdump -i wlan0 -nn dst host 192.168.50.102
```

### Desafio

Modifique os filtros para capturar:

1. Somente tráfego originado pelo PC-02;
2. Somente tráfego destinado ao PC-02;
3. Todo o tráfego envolvendo o PC-02;
4. Somente tráfego ICMP do PC-02.

## Exemplo 08 — Salvando uma captura

Uma captura pode ser armazenada em um arquivo para posterior análise.

Execute:

```bash
sudo tcpdump -i wlan0 -nn -w laboratorio.pcap
```

Gere alguns tipos de tráfego na rede e depois interrompa a captura.

O arquivo:

```text
laboratorio.pcap
```

contém os pacotes capturados.

Podemos posteriormente realizar sua leitura utilizando o próprio `tcpdump`:

```bash
tcpdump -nn -r laboratorio.pcap
```

Ou abrir o arquivo em uma ferramenta gráfica de análise de pacotes, como o **Wireshark**.

## Exemplo 09 — Analisando o conteúdo dos pacotes

Para visualizar o conteúdo dos pacotes em formato ASCII:

```bash
sudo tcpdump -i wlan0 -A port 8000
```

Para visualizar os dados em hexadecimal e ASCII:

```bash
sudo tcpdump -i wlan0 -X port 8000
```

Compare os resultados e observe a diferença entre:

* cabeçalhos dos protocolos;
* dados transportados;
* representação hexadecimal;
* representação ASCII.

## Exemplo 10 — Sniffing de redes sem fio

O `tcpdump` também pode ser utilizado para captura de tráfego em interfaces sem fio que suportem **modo monitor**.

Primeiro, verifique as capacidades da interface:

```bash
iw list
```

Procure por:

```text
Supported interface modes:
    ...
    * monitor
```

Caso o hardware e o driver ofereçam suporte, a interface poderá ser configurada para modo monitor.

Por exemplo:

```bash
sudo ip link set wlan0 down
sudo iw dev wlan0 set type monitor
sudo ip link set wlan0 up
```

Verifique:

```bash
iw dev wlan0 info
```

A interface deverá apresentar:

```text
type monitor
```

A captura pode então ser realizada com:

```bash
sudo tcpdump -i wlan0 -e -s 256
```

ou salva em arquivo:

```bash
sudo tcpdump -i wlan0 -e -s 256 -w wifi.pcap
```

> O suporte ao modo monitor depende do chipset, driver e sistema operacional. Nem toda interface sem fio oferece suporte adequado a essa funcionalidade.

## Desafio final

A partir de uma captura realizada durante o laboratório, responda:

1. Qual é o endereço IP de cada computador observado?
2. Qual é o endereço MAC do gateway?
3. Quais protocolos de rede foram identificados?
4. Qual computador iniciou uma determinada conexão TCP?
5. Qual porta foi utilizada pelo servidor?
6. É possível identificar o estabelecimento da conexão TCP?
7. É possível identificar consultas DNS?
8. Quais mensagens ARP foram observadas?
9. Quais informações podem ser observadas sem conhecer o conteúdo da aplicação?
10. Quais informações deixam de estar disponíveis quando a aplicação utiliza criptografia?

## Conclusão

O objetivo deste projeto é proporcionar uma experiência prática de **captura e análise de tráfego de rede**, permitindo que o discente compreenda, por meio de experimentos reproduzíveis, como os protocolos de comunicação podem ser observados em diferentes camadas da arquitetura de redes.

O `tcpdump` será utilizado como ferramenta principal para a captura, filtragem e inspeção inicial dos pacotes. Os arquivos `.pcap` gerados poderão posteriormente ser analisados com outras ferramentas, como o Wireshark.

Os experimentos também permitem compreender conceitos fundamentais de **ARP, ICMP, DNS, TCP, HTTP e 802.11**, relacionando os conceitos apresentados na disciplina com o comportamento observado em uma rede real, porém controlada para fins educacionais.

O laboratório deve ser utilizado exclusivamente em ambientes autorizados, com dispositivos e tráfego pertencentes ao experimento.
