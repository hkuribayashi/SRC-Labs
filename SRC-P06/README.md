# Demonstração de Criptografia Assimétrica e Assinatura Digital com OpenSSL

Este projeto é uma demonstração reproduzível de criptografia assimétrica utilizando o OpenSSL, permitindo executar, diretamente na linha de comando do Linux, operações de geração de pares de chaves, criptografia, descriptografia, assinatura digital e verificação de assinaturas.

O projeto é destinado aos discentes da disciplina SI01033 (Segurança em Redes de Computadores), do Curso de Sistemas de Informação da Unifesspa, que desejam experimentar ferramentas criptográficas, reproduzir resultados e compreender como chaves públicas e privadas podem ser utilizadas para proteger informações e verificar a autenticidade de arquivos.

A atividade está organizada em dois experimentos principais:

1. Criptografia assimétrica: utilizar a chave pública de outro discente para criptografar um arquivo, que somente poderá ser recuperado com a chave privada correspondente.

2. Assinatura digital: utilizar a própria chave privada para assinar um arquivo, permitindo que outros discentes verifiquem sua assinatura utilizando a chave pública correspondente.

Os experimentos serão realizados com o algoritmo RSA, utilizando chaves de 3072 bits e o OpenSSL.

## O que é criptografia assimétrica?

A criptografia assimétrica é uma técnica criptográfica baseada na utilização de duas chaves matematicamente relacionadas, denominadas chave pública e chave privada.

A chave pública pode ser compartilhada com outras pessoas, enquanto a chave privada deve permanecer sob controle exclusivo de seu proprietário.

As duas chaves possuem funções distintas, dependendo da operação criptográfica realizada.

| Operação                  | Chave utilizada         | Finalidade                          |
| ------------------------- | ----------------------- | ----------------------------------- |
| Criptografia              | Pública do destinatário | Proteger a confidencialidade        |
| Descriptografia           | Privada do destinatário | Recuperar o conteúdo original       |
| Assinatura digital        | Privada do remetente    | Produzir uma assinatura verificável |
| Verificação da assinatura | Pública do remetente    | Verificar integridade e assinatura  |

Diferentemente da criptografia simétrica, não é necessário compartilhar uma chave secreta entre remetente e destinatário.

Neste experimento, utilizaremos o RSA (Rivest–Shamir–Adleman), um algoritmo de criptografia assimétrica amplamente conhecido.

## Preparação do ambiente

Os comandos apresentados foram preparados para execução no terminal do Kali Linux.

Verifique se o OpenSSL está instalado:

```
openssl version
```

Crie um diretório para organizar os arquivos do experimento:

```
mkdir experimento-rsa
cd experimento-rsa
```

Crie um arquivo de texto que será utilizado nos experimentos:

```
echo "Mensagem secreta para o experimento RSA." > mensagem.txt
```

Visualize seu conteúdo:

```
cat mensagem.txt
```

## Gerando um par de chaves RSA

O primeiro passo consiste em gerar um par de chaves RSA.

Execute:

```
openssl genpkey \
  -algorithm RSA \
  -aes-256-cbc \
  -out chave_privada.pem \
  -pkeyopt rsa_keygen_bits:3072
```

O comando solicitará uma senha para proteger o arquivo da chave privada. Informe uma senha e confirme-a.

Os principais parâmetros são:

- `genpkey`: gera uma chave privada.
- `-algorithm RSA`: seleciona o algoritmo RSA.
- `-aes-256-cbc`: protege a chave privada armazenada utilizando criptografia simétrica.
- `-out`: especifica o arquivo de saída.
- `rsa_keygen_bits:3072`: define o tamanho da chave RSA em 3072 bits.

O arquivo `chave_privada.pem` conterá a chave privada, protegida pela senha informada.

Atenção: a chave privada não deve ser publicada nem compartilhada com outros discentes. A senha protege seu armazenamento, mas não substitui a necessidade de manter o arquivo em segurança.

### Extraindo a chave pública

A chave pública pode ser extraída a partir da chave privada.

Execute:

```
openssl pkey \
  -in chave_privada.pem \
  -pubout \
  -out chave_publica.pem
```

O OpenSSL solicitará a senha utilizada para proteger a chave privada.

O parâmetro `-pubout` determina que somente a parte pública seja exportada.

Visualize o conteúdo:

```
cat chave_publica.pem
```

O arquivo terá uma estrutura semelhante a:

```
-----BEGIN PUBLIC KEY-----
MIIBojANBgkqhkiG9w0BAQEFAA...
...
-----END PUBLIC KEY-----
```

A chave pública pode ser distribuída livremente. Entretanto, é importante verificar se ela realmente pertence à pessoa que afirma ser sua proprietária.

## Publicando a chave pública em um repositório

Para permitir a troca de mensagens criptografadas e a verificação de assinaturas digitais entre os discentes, cada participante deverá disponibilizar sua chave pública em um repositório acessível aos colegas.

Para este experimento, utilizaremos um respositório fictício na forma de uma pasta no [Google Drive](https://drive.google.com/drive/folders/1ATCyGrTtzUaxrH4411TEclxgQmAI00-k?usp=sharing).

Ao gerar a sua chave pública, faça uma cópia da mesma usando o seguinte padrão:

```
hugo_chave_publica.pem
```

Assim será possível identificar de quem é a chave no exemplo.

### Procedimento para publicação

1. Acesse o repositório do Google Drive 
2. Defina o nome do arquivo como `nome_chave_publica.pem`.
3. Copie todo o conteúdo completo da chave pública, incluindo as linhas `BEGIN PUBLIC KEY` e `END PUBLIC KEY`.
4. Publique a sua chave no repositório do Google Drive
5. Informe a publicação da sua chave para os demais colegas, utilizando o canal definido pelo professor.

Cada discente deverá selecionar a chave pública de outro participante para realizar o primeiro experimento.

Importante: publique exclusivamente a chave pública. Nunca publique `chave_privada.pem`, a senha da chave privada ou outros arquivos secretos.


## Experimento 1 — Criptografando um arquivo com a chave pública

Neste experimento, um discente deverá criptografar uma mensagem utilizando a chave pública de outro participante.

Considere dois participantes:

- Alice: deseja enviar uma mensagem confidencial.
- Bob: receberá a mensagem e realizará sua descriptografia.

Fluxo conceitual da criptografia assimétrica com RSA.

### Obtendo a chave pública do destinatário

Alice deverá acessar o repositório de Bob e obter sua chave pública.

Salve o conteúdo no arquivo:

```
bob_chave_publica.pem
```

### Criptografando a mensagem

O OpenSSL disponibiliza o comando `pkeyutl` para realizar operações criptográficas com chaves assimétricas.

Execute:

```
openssl pkeyutl -encrypt \
  -pubin \
  -inkey bob_chave_publica.pem \
  -in mensagem.txt \
  -out mensagem_criptografada_para_bob.enc \
  -pkeyopt rsa_padding_mode:oaep \
  -pkeyopt rsa_oaep_md:sha256 \
  -pkeyopt rsa_mgf1_md:sha256
```

Os principais parâmetros são:

- `-encrypt`: executa a criptografia.
- `-pubin`: informa que a chave de entrada é pública.
- `-inkey`: especifica a chave pública.
- `-in`: indica o arquivo original.
- `-out`: indica o arquivo criptografado.
- `rsa_padding_mode:oaep`: utiliza o preenchimento OAEP.
- `rsa_oaep_md:sha256`: utiliza SHA-256 no OAEP.
- `rsa_mgf1_md:sha256`: utiliza SHA-256 na função MGF1.

O arquivo `mensagem_criptografada_para_bob.enc` conterá os dados criptografados.

Para visualizar os primeiros bytes:

```
xxd -l 64 mensagem_criptografada_para_bob.enc
```

Para verificar o tamanho:

```
wc -c mensagem_criptografada_para_bob.enc
```

Resultado esperado:

```
384 mensagem_criptografada_para_bob.enc
```

Como estamos utilizando RSA com chave de 3072 bits, o resultado possui 384 bytes.

### Enviando o arquivo criptografado

Alice deverá disponibilizar o arquivo `mensagem_criptografada_para_bob.enc` para Bob, utilizando o meio de compartilhamento definido para a atividade.

Bob deverá salvar o arquivo no diretório do experimento.

### Descriptografando a mensagem

Bob utilizará sua própria chave privada para recuperar a mensagem.

Execute:

```
openssl pkeyutl -decrypt \
  -inkey chave_privada.pem \
  -in mensagem_criptografada_para_bob.enc \
  -out mensagem_recuperada.txt \
  -pkeyopt rsa_padding_mode:oaep \
  -pkeyopt rsa_oaep_md:sha256 \
  -pkeyopt rsa_mgf1_md:sha256
```

O OpenSSL solicitará a senha da chave privada.

Visualize o conteúdo recuperado:

```
cat mensagem_recuperada.txt
```

O resultado deverá corresponder ao conteúdo original enviado por Alice.

### Verificando a recuperação

Se o arquivo original também estiver disponível para comparação, execute:

```
cmp mensagem.txt mensagem_recuperada.txt
```

O comando não apresentará nenhuma saída caso os arquivos sejam idênticos.

Também é possível calcular o hash:

```
sha256sum mensagem_recuperada.txt
```

### Limitação importante do RSA

O RSA não é adequado para criptografar diretamente arquivos grandes.

Com uma chave RSA de 3072 bits e OAEP utilizando SHA-256, o tamanho máximo da mensagem é:

\\[ 384 - 2(32) - 2 = 318\text{ bytes} \\]

Portanto, o experimento deverá utilizar arquivos de texto pequenos, com no máximo 318 bytes.

Em aplicações reais, costuma-se utilizar criptografia híbrida: o arquivo é criptografado com um algoritmo simétrico, como AES, e a chave simétrica é protegida por meio de criptografia assimétrica.


## Experimento 2 — Assinando um arquivo com a chave privada

Neste experimento, cada discente deverá utilizar sua própria chave privada para produzir uma assinatura digital.

Diferentemente do primeiro experimento, o objetivo não é ocultar o conteúdo do arquivo, mas permitir que outras pessoas verifiquem sua integridade e a assinatura associada à chave pública do remetente.

Fluxo conceitual de geração e verificação de uma assinatura digital.

### Criando o documento

Crie um arquivo para ser assinado:

```
echo "Documento para teste de assinatura digital." > documento.txt
```

Visualize seu conteúdo:

```
cat documento.txt
```

### Gerando a assinatura digital

Utilizaremos o comando `openssl dgst`, que permite calcular um resumo criptográfico e produzir uma assinatura digital.

Execute:

```
openssl dgst -sha256 \
  -sign chave_privada.pem \
  -out assinatura.bin \
  documento.txt
```

O OpenSSL solicitará a senha da chave privada.

O comando utiliza SHA-256 para calcular o resumo criptográfico do documento e produz uma assinatura RSA com preenchimento PKCS#1 v1.5.

Os principais parâmetros são:

- `dgst`: executa operações envolvendo resumos criptográficos.
- `-sha256`: seleciona o algoritmo de hash SHA-256.
- `-sign`: indica a chave privada utilizada na assinatura.
- `-out`: especifica o arquivo que armazenará a assinatura.

O arquivo `assinatura.bin` conterá a assinatura digital.

Para verificar seu tamanho:

```
wc -c assinatura.bin
```

Resultado esperado:

```
384 assinatura.bin
```

A assinatura RSA produzida com a chave de 3072 bits possui 384 bytes.

### Compartilhando o documento e a assinatura

O discente deverá compartilhar com outro participante:

1. `documento.txt`: documento original.
2. `assinatura.bin`: assinatura digital produzida.
3. Endereço da chave pública publicada no repositório.

A chave privada não deve ser compartilhada.

### Verificando a assinatura digital

O destinatário deverá obter a chave pública do autor e salvar o arquivo como:

```
chave_publica_alice.pem
```

Execute:

```
openssl dgst -sha256 \
  -verify chave_publica_alice.pem \
  -signature assinatura.bin \
  documento.txt
```

Se a assinatura for válida, o OpenSSL apresentará:

```
Verified OK
```

Esse resultado indica que a assinatura corresponde ao documento e à chave pública utilizada na verificação.

Entretanto, isso não comprova, isoladamente, a identidade civil do autor. Para associar a chave pública a uma pessoa, é necessário confiar no procedimento utilizado para validar a propriedade da chave.

### Experimento adicional: alterando o documento

Para observar o comportamento da assinatura diante de modificações, altere o conteúdo do documento:

```
echo "Conteudo alterado." >> documento.txt
```

Execute novamente:

```
openssl dgst -sha256 \
  -verify chave_publica_alice.pem \
  -signature assinatura.bin \
  documento.txt
```

Resultado esperado:

```
Verification failure
```

A verificação falhará porque o conteúdo do documento foi modificado após a geração da assinatura.

Isso demonstra que a assinatura digital permite detectar alterações no documento assinado.

## Comparando os dois experimentos

| Característica                       | Criptografia assimétrica           | Assinatura digital                       |
| ------------------------------------ | ---------------------------------- | ---------------------------------------- |
| Objetivo principal                   | Confidencialidade                  | Integridade e autenticação da assinatura |
| Chave usada na operação inicial      | Pública do destinatário            | Privada do remetente                     |
| Chave usada na operação final        | Privada do destinatário            | Pública do remetente                     |
| Conteúdo original permanece legível? | Não, no arquivo cifrado            | Sim                                      |
| Detecta alterações?                  | Não oferece autenticação por si só | Sim, durante a verificação               |
| Comando OpenSSL                      | `pkeyutl`                          | `dgst`                                   |

É importante observar que assinar um documento não significa criptografá-lo.

A assinatura digital não impede que outras pessoas leiam seu conteúdo. Ela permite verificar se o documento foi alterado e se a assinatura corresponde à chave pública utilizada na verificação.

## Arquivos gerados nos experimentos

Ao final da atividade, o diretório poderá conter os seguintes arquivos:

| Arquivo                   | Descrição                              |
| ------------------------- | -------------------------------------- |
| `chave_privada.pem`       | Chave privada RSA protegida por senha  |
| `chave_publica.pem`       | Chave pública RSA                      |
| `bob_chave_publica.pem`   | Chave pública de outro discente        |
| `mensagem.txt`            | Mensagem original                      |
| `mensagem.enc`            | Mensagem criptografada                 |
| `mensagem_recuperada.txt` | Mensagem descriptografada              |
| `documento.txt`           | Documento utilizado na assinatura      |
| `assinatura.bin`          | Assinatura digital                     |
| `chave_publica_alice.pem` | Chave pública utilizada na verificação |

## Questões para reflexão

1. Qual é a principal diferença entre criptografia simétrica e assimétrica?
2. Por que a chave pública pode ser compartilhada, enquanto a chave privada deve permanecer secreta?
3. Por que a criptografia assimétrica permite trocar mensagens confidenciais sem compartilhar previamente uma chave secreta?
4. O que acontece quando tentamos descriptografar uma mensagem utilizando uma chave privada diferente?
5. Por que o RSA não é normalmente utilizado para criptografar diretamente arquivos grandes?
6. Qual é a função do preenchimento OAEP na criptografia RSA?
7. Qual é a diferença entre criptografar um documento e assiná-lo digitalmente?
8. Por que a assinatura digital utiliza a chave privada do remetente?
9. Como a chave pública permite verificar uma assinatura digital?
10. O que acontece com a assinatura quando o documento é modificado?
11. Uma assinatura válida garante que a pessoa identificada como remetente realmente produziu o documento? Quais condições adicionais seriam necessárias?
12. Quais riscos existem quando uma chave pública é obtida de um repositório sem verificação de sua origem?

## Considerações de segurança

Este experimento possui finalidade exclusivamente educacional.

O RSA com OAEP e SHA-256 é adequado para demonstrar criptografia assimétrica de pequenas mensagens. Para arquivos maiores, recomenda-se utilizar criptografia híbrida.

Na assinatura digital, utilizamos RSA com SHA-256 e preenchimento PKCS#1 v1.5. Em novos sistemas, RSA-PSS é geralmente preferível quando há suporte e interoperabilidade adequados.

A segurança dos experimentos depende da proteção das chaves privadas e da confiabilidade das chaves públicas utilizadas.

A publicação de uma chave pública em um repositório não garante automaticamente sua autenticidade. Um atacante poderia substituir uma chave pública e induzir terceiros a criptografar informações para a chave errada.

Por esse motivo, aplicações reais utilizam mecanismos adicionais, como certificados digitais, infraestruturas de chaves públicas (PKI) ou validação de impressões digitais das chaves.

## Conclusão

O objetivo deste projeto é permitir que os discentes compreendam, por meio de experimentos reproduzíveis no Kali Linux, como a criptografia assimétrica e as assinaturas digitais utilizam pares de chaves públicas e privadas para atender a diferentes requisitos de segurança.

O primeiro experimento demonstra como uma chave pública pode ser utilizada para proteger uma mensagem e como somente a chave privada correspondente permite sua recuperação.

O segundo experimento demonstra como uma chave privada pode produzir uma assinatura digital verificável por terceiros, permitindo detectar modificações no conteúdo assinado.

A publicação das chaves públicas em um repositório compartilhado possibilita que os discentes realizem os experimentos entre si, simulando um ambiente de comunicação entre diferentes participantes.

Dessa forma, a atividade permite compreender, na prática, três propriedades fundamentais da segurança da informação: confidencialidade, integridade e autenticidade, bem como as limitações e os cuidados necessários na utilização de mecanismos criptográficos.