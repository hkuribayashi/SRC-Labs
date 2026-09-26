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

## Exemplo 04 — Capturando DNS

Para observar consultas DNS:

```bash
sudo tcpdump -i wlan0 -nn port 53
```

Em outro terminal, execute:

```bash
host -t A unifesspa.edu.br
```

ou:

```bash
host -t MX unifesspa.edu.br
```

Observe:

* endereço IP de origem;
* endereço IP de destino;
* porta utilizada;
* protocolo de transporte;
* consulta DNS;
* resposta DNS.


## Exemplo 05 — Salvando uma captura

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


## Exemplo 06 — Sniffing de redes sem fio

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


Utilize o comando abaixo para monitorar de modo geral as redes sem fio disponíveis no alcance da sua antena:

```bash
sudo airodump-ng wlan0
```

Agora vamos aplicar o filtro de endereço MAC para filtrar em um único ponto de acesso:

```bash
sudo airodump-ng wlan0 -d 04:95:E6:FD:16:91
```

Alternativamente, podemos filtar pro canal e/ou por ESSID de rede:

```bash
sudo airodump-ng wlan0 -c 1 --essid "Tenda_FD1690"
```

Por fim, vamos aproveitar e salvar o tráfego coletado com:

```bash
sudo airodump-ng wlan0 -c 1 --essid "Tenda_FD1690" -w arquivo
```

> O comando acima deve ter gerardo um arquivo.cap. Verifique se o arquivo foi criado assim como seus meta-dados.


É possível analisar o arquivo com o wireshar, tal como:

```bash
sudo wireshark arquivo.cap
```

Ou usar o aplicativo abaixo para verificar por pacotes EAPOL:

```bash
sudo aircrack-ng arquivp.cap -w senhas.txt -l saida

```

Ao final, vefifique se o arquivo de saída foi criado e se ele contém a senha buscada.



## Conclusão

O objetivo deste projeto é proporcionar uma experiência prática de **captura e análise de tráfego de rede**, permitindo que o discente compreenda, por meio de experimentos reproduzíveis, como os protocolos de comunicação podem ser observados em diferentes camadas da arquitetura de redes.

O laboratório deve ser utilizado exclusivamente em ambientes autorizados, com dispositivos e tráfego pertencentes ao experimento.
