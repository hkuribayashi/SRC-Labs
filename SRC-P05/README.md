# Demonstração de Criptografia Simétrica com OpenSSL

Este projeto é uma demonstração reproduzível de criptografia simétrica utilizando o OpenSSL, permitindo que você execute, diretamente na linha de comando do Linux, as operações de geração de chaves, criptografia e descriptografia de arquivos.

O projeto é destinado aos discentes da disciplina SI01033 (Segurança em Redes de Computadores), do Curso de Sistemas de Informação da Unifesspa, que desejam experimentar ferramentas criptográficas, reproduzir os resultados e compreender como uma chave simétrica é utilizada para proteger e recuperar informações.

## O que é criptografia simétrica?

A criptografia simétrica é uma técnica na qual uma mesma chave secreta é utilizada para criptografar e descriptografar os dados.

Diferentemente da criptografia assimétrica, que utiliza um par de chaves pública e privada, a criptografia simétrica depende do compartilhamento seguro da chave secreta entre as partes que precisam trocar informações.

Um dos algoritmos mais conhecidos é o AES (*Advanced Encryption Standard*), que opera com blocos de 128 bits e aceita chaves de 128, 192 ou 256 bits.

Neste experimento, utilizaremos o AES-256, com uma chave de 256 bits (32 bytes), e o modo de operação CBC (*Cipher Block Chaining*).

O objetivo é observar como um arquivo pode ser transformado em um conteúdo cifrado e posteriormente recuperado com a mesma chave.

## Preparação do ambiente

Os comandos apresentados foram preparados para execução no terminal do Kali Linux. O OpenSSL normalmente já está instalado nessa distribuição.

Verifique a instalação:

```bash
openssl version
```

Crie um diretório para organizar os arquivos do experimento:

```bash
mkdir experimento-aes
cd experimento-aes
```

Crie um arquivo de texto que será utilizado como entrada:

```bash
echo "Mensagem secreta para o experimento de criptografia simetrica." > mensagem.txt
```

Visualize o conteúdo original:

```bash
cat mensagem.txt
```

## Gerando uma chave simétrica

Para criptografar um arquivo utilizando AES-256, precisamos de uma chave secreta de 256 bits.

O OpenSSL permite gerar bytes aleatórios por meio do comando `openssl rand`.

Execute:

```bash
openssl rand -out chave_aes.bin 32
```

O comando gera 32 bytes aleatórios e os armazena no arquivo `chave_aes.bin`.

O parâmetro `-out` especifica o arquivo de saída, enquanto `32` determina a quantidade de bytes gerados.

Podemos verificar o tamanho do arquivo:

```bash
wc -c chave_aes.bin
```

Resultado esperado:

```text
32 chave_aes.bin
```

Para visualizar a chave em hexadecimal:

```bash
xxd -p chave_aes.bin
```

Cada byte é representado por dois dígitos hexadecimais. Portanto, uma chave de 32 bytes possui 64 dígitos hexadecimais.

**Atenção:** a saída hexadecimal representa a própria chave secreta. Não publique esse conteúdo nem compartilhe o arquivo da chave com pessoas não autorizadas.

## Gerando o vetor de inicialização (IV)

No modo CBC, além da chave, precisamos de um vetor de inicialização, conhecido como IV (*Initialization Vector*).

O IV possui 128 bits (16 bytes), correspondentes ao tamanho de um bloco AES.

Gere um IV aleatório:

```bash
openssl rand -hex 16 > iv.hex
```

Visualize seu conteúdo:

```bash
cat iv.hex
```

O arquivo conterá 32 dígitos hexadecimais, que representam os 16 bytes do IV.

O IV não precisa ser secreto, mas deve ser armazenado para que a descriptografia possa ser realizada posteriormente. Para AES-CBC, ele deve ser imprevisível e não deve ser reutilizado com a mesma chave.

## Criptografando o arquivo

Agora temos os elementos necessários:

1. `mensagem.txt`: arquivo original;
2. `chave_aes.bin`: chave simétrica de 256 bits;
3. `iv.hex`: vetor de inicialização de 128 bits.

O OpenSSL aceita a chave e o IV diretamente em formato hexadecimal. Para isso, precisamos converter a chave binária para hexadecimal e armazenar o resultado em uma variável do terminal.

Execute:

```bash
CHAVE=$(xxd -p -c 256 chave_aes.bin | tr -d '\n')
IV=$(cat iv.hex)
```

Criptografe o arquivo:

```bash
openssl enc -aes-256-cbc -e \
  -K "$CHAVE" \
  -iv "$IV" \
  -in mensagem.txt \
  -out mensagem.enc
```

Os principais parâmetros são:

- `enc`: executa operações de criptografia simétrica;
- `-aes-256-cbc`: seleciona AES-256 no modo CBC;
- `-e`: indica a operação de criptografia;
- `-K`: informa a chave em hexadecimal;
- `-iv`: informa o vetor de inicialização em hexadecimal;
- `-in`: indica o arquivo de entrada;
- `-out`: indica o arquivo de saída.

O arquivo `mensagem.enc` conterá o resultado da criptografia. Ele não será um arquivo de texto legível como o original.

Para examinar os primeiros bytes do arquivo cifrado:

```bash
xxd -l 64 mensagem.enc
```

Também podemos comparar os tamanhos:

```bash
ls -l mensagem.txt mensagem.enc
```

O AES-CBC exige que os dados sejam processados em blocos de 16 bytes. Com o preenchimento padrão utilizado pelo OpenSSL, o arquivo cifrado terá um tamanho múltiplo de 16 bytes.

## Descriptografando o arquivo

Para recuperar o conteúdo original, precisamos utilizar a mesma chave e o mesmo IV empregados na criptografia.

Se as variáveis `CHAVE` e `IV` ainda estiverem disponíveis no terminal, execute:

```bash
openssl enc -aes-256-cbc -d \
  -K "$CHAVE" \
  -iv "$IV" \
  -in mensagem.enc \
  -out mensagem_recuperada.txt
```

Caso tenha fechado o terminal, recupere os valores antes de executar a descriptografia:

```bash
CHAVE=$(xxd -p -c 256 chave_aes.bin | tr -d '\n')
IV=$(cat iv.hex)
```

O parâmetro `-d` indica que a operação é de descriptografia.

Visualize o conteúdo recuperado:

```bash
cat mensagem_recuperada.txt
```

O conteúdo deverá ser igual ao arquivo original.

## Verificando a recuperação do arquivo

Para verificar se os arquivos são idênticos, utilize o comando `cmp`:

```bash
cmp mensagem.txt mensagem_recuperada.txt
```

Se não houver diferenças, o comando não exibirá nenhuma mensagem.

Podemos confirmar o resultado verificando o código de retorno:

```bash
echo $?
```

Resultado esperado:

```text
0
```

O código `0` indica que os arquivos são idênticos byte a byte.

Outra forma de comparar os arquivos é calcular seus hashes SHA-256:

```bash
sha256sum mensagem.txt mensagem_recuperada.txt
```

Os dois hashes devem ser iguais.

## Experimento adicional: utilizando uma senha

Até aqui, utilizamos uma chave AES aleatória, armazenada diretamente em um arquivo binário.

O OpenSSL também permite criptografar arquivos a partir de uma senha. Nesse caso, a senha não é necessariamente a chave AES: o OpenSSL deriva a chave e os parâmetros necessários a partir da senha e de um salt.

Para testar essa alternativa, execute:

```bash
openssl enc -aes-256-cbc -e -pbkdf2 \
  -in mensagem.txt \
  -out mensagem_senha.enc
```

O OpenSSL solicitará uma senha. Informe uma senha para o experimento e confirme-a quando solicitado.

Para descriptografar:

```bash
openssl enc -aes-256-cbc -d -pbkdf2 \
  -in mensagem_senha.enc \
  -out mensagem_senha_recuperada.txt
```

Informe a mesma senha utilizada na criptografia.

Verifique o resultado:

```bash
cmp mensagem.txt mensagem_senha_recuperada.txt
```

Se o comando não apresentar diferenças, a recuperação foi bem-sucedida.

Essa experiência permite comparar duas abordagens distintas:

- **Chave aleatória:** o programa gera diretamente os bytes que compõem a chave criptográfica.
- **Senha:** o programa deriva a chave a partir de uma senha e de parâmetros de derivação.

Uma senha fraca pode comprometer a segurança mesmo quando o algoritmo de criptografia utilizado é robusto.

## Comparando os arquivos

Ao final do experimento, o diretório deverá conter arquivos semelhantes aos seguintes:

| Arquivo | Descrição |
|---|---|
| `mensagem.txt` | Conteúdo original |
| `chave_aes.bin` | Chave AES aleatória de 256 bits |
| `iv.hex` | Vetor de inicialização do modo CBC |
| `mensagem.enc` | Arquivo criptografado com a chave explícita |
| `mensagem_recuperada.txt` | Arquivo recuperado por descriptografia |
| `mensagem_senha.enc` | Arquivo criptografado com uma senha |
| `mensagem_senha_recuperada.txt` | Arquivo recuperado a partir da senha |

## Questões para reflexão

1. Qual é a diferença entre uma chave simétrica e uma senha?
2. Por que a chave AES precisa ser mantida em segredo, enquanto o IV pode ser armazenado junto ao arquivo cifrado?
3. O que acontece quando tentamos descriptografar o arquivo utilizando uma chave diferente?
4. Por que o tamanho do arquivo cifrado pode ser diferente do tamanho do arquivo original?
5. Qual é a finalidade do preenchimento (*padding*) no modo CBC?
6. Por que a criptografia simétrica exige um mecanismo seguro para compartilhar a chave entre remetente e destinatário?
7. O que aconteceria se o arquivo cifrado fosse alterado antes da descriptografia?
8. Por que a comparação de hashes iguais não deve ser confundida com uma prova de autenticidade do remetente?

## Considerações de segurança

Este experimento possui finalidade exclusivamente educacional.

O AES-256-CBC oferece confidencialidade, mas não garante, por si só, a integridade ou a autenticidade do conteúdo cifrado. Uma alteração nos dados pode passar despercebida ou provocar erros durante a descriptografia.

Em aplicações reais, recomenda-se utilizar criptografia autenticada, como AES-GCM, ou combinar CBC com um mecanismo de autenticação criptográfica corretamente implementado.

A chave simétrica também deve ser armazenada de forma segura. Quem obtiver a chave e o IV poderá tentar recuperar o conteúdo do arquivo.

## Conclusão

O objetivo deste projeto é permitir que os discentes compreendam, por meio de experimentos reproduzíveis no Kali Linux, como gerar uma chave simétrica, criptografar arquivos com OpenSSL e recuperar o conteúdo original por meio da descriptografia.

A atividade também permite distinguir o uso de chaves aleatórias do uso de senhas para derivação de chaves e discutir as limitações do modo AES-CBC, especialmente em relação à integridade e à autenticidade dos dados.
