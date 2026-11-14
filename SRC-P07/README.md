# SRC-P08 (Requisições HTTP e HTTPS)

Este projeto é uma demonstração reproduzível do conceito de requisições,
HTTP e HTTPs para que você mesmo possa fazer o trabalho na linha de comando.

Este projeto é para alunos da disciplina SI01033 (Segurança em Redes de Computadores) 
do Curso de Sistemas de Informação da Unifesspa, que querem testar ferramentas 
de criptografia para  reproduzir os próprios resultados ou brincar com o conceito 
para criar variações dos resultados a serem obtidos.

## Ferramentas

Instalar a ferramenta *netcat* via terminal do Linux:

    $ sudo apt update
    $ sudo apt install netcat

Com a ferramenta *netcat* instalada, ela pode ser utilizada da seguinte forma:

    $ nc <endereco_ip> <porta>

Onde, <endereco_ip> deve ser substituído pelo endereço IP do servidor e <porta>
pelo número da porta onde roda o serviço Web, conforme o exemplo a seguir:

    $ nc 200.129.138.99 80  


### Testando uma requisição HTTP

Para testar uma requisição HTTP é necessário abrir uma conexão TCP com 
o servidor de destino, por meio do aplicativo *netcat*, e posteriormente
realizar uma requisição HTTP conforme exemplo abaixo:

    $ nc 200.129.138.99 80
    GET / HTTP/1.1
    Host: coordenador.fadesp.org.br

Após digitar o texto acima, duas linhas em branco devem ser inseridas 
(com a tecla ENTER), para informar que já finalizamos a requisição.

Em seguida, o servidor deve devolver uma resposta, conforme exemplificado
na figura `Imagem1.png`, abaixo.

![Imagem1](/Imagem1.png)

### Testando uma requisição HTTP

Para testar uma requisição HTTPS é necessário abrir uma conexão TCP, 
porém neste caso utilizaremos um aplicativo chamado *openssl*, que será
responsável por estabelecer o tunel SSL/TLS.

Com o uso do aplicativo *openssl* é possível abrir uma conexão SSL/TLS
com um servidor por meio do comando abaixo. Observe que agora estamos
utilizando a porta 443, padrão para comunicações HTTPS. Estamos utilizando 
o *openssl* porque o aplicativo *netcat* não possui suporte a conexões SSL/TLS.

    $ openssl s_client -ign_eof -connect <endereco_ip>:443

O comando acima abre uma conexão SSL/TLS com um servidor que tem suporte a HTTPS.
Porém, ainda precisamos de fato enviar o pedido (requisição HTTP). Até então, apenas
a conexão TCP e o túnel SSL/TLS foi estabelecido. Ainda precisamos *falar* HTTP para 
fazer o pedido de uma página web.

Para isso criamos o arquivo `requisicao.txt`, cujo conteúdo por ser visto abaixo.

    GET / HTTP/1.1
    Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
    Accept-Encoding: gzip, deflate, br
    Accept-Language: en-US,en;q=0.9,pt-BR;q=0.8,pt;q=0.7
    Connection: keep-alive
    Host: coordenador.fadesp.org.br

Observe que o arquivo deve possuir duas linhas em branco ao final. Para combinar o arquivo com o *openssl*
basta executar o seguinte comando abaixo:

    $ cat requisicao.txt | openssl s_client -ign_eof -connect <endereco_ip>:443

## Conclusão

O objetivo deste projeto é simplesmente para propósitos educacionais, 
para permitir ao discente, entender as diferenças entre requisições HTTP e HTTPs.
