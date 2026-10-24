# Demonstracao de Modos de Operação ECB 

Este projeto é uma demonstração reproduzível do conceito "ECB Penguin",
para que você mesmo possa fazer o trabalho na linha de comando para criar 
suas próprias imagens cifradas.

Este projeto é para alunos da disciplina SI01033 (Segurança em Redes de Computadores) 
do Curso de Sistemas de Informação da Unifesspa, que querem testar ferramentas 
de criptografia para  reproduzir os próprios resultados ou brincar com o conceito 
para criar variações dos resultados a serem obtidos.

## O que é o Projeto ECB Penguin?

O algoritmo de criptografia mais comum, AES, usa uma *cifra de bloco* com
blocos de 128 bits.

Uma *cifra de bloco* sempre criptografa o mesmo conteúdo da mesma maneira, dado
a mesma chave (processo determinístico).

Podemos demonstrar isso criptografando imagens de desenhos animados. Figuras/Desenhos 
tendem a ter regiões onde todas as cores são as mesmas e, portanto, irão gerar a mesma 
criptografia ao usar uma cifra de bloco.

A figura mais famosa por demonstrar isso, de onde vem esse problema
seu nome, é o mascote pinguim Linux conhecido como "Tux" (autoria de Larry Ewing 
lewing@isc.tamu.edu [Referência](https://commons.wikimedia.org/wiki/File:Tux.png)):

![Tux](/Tux.png)

Observe como grandes regiões do desenho são completamente brancas (0xFFFFFF)
ou completamente preto (0x000000).

Na imagem abaixo, nós o criptografamos usando o modo ECB.

![Tux-ecb](/Tux.ecb.png)

Como você pode ver, a imagem ainda é reconhecível como um pinguim.

### Testando o Modo ECB

O objetivo deste projeto não é descrever o pinguim ECB, mas ajudar o discente reproduzi-lo.

Começamos com o arquivo `Tux.ppm`. Ele está em um formato bruto descompactado, conhecido 
como PPM.

O formato de imagem PPM tem quatro campos de texto seguidos por dados binários:
1. O tipo de arquivo; 
2. A largura em pixels; 
3. A altura em pixels; e 
4. O número de cores (geralmente 255 ou 256 para cor de 8 bits).

O restante do arquivo são dados binários contendo a imagem bruta e descompactada.

Podemos recuperar o cabeçalho deste arquivo fazendo:

    $ head -n 4 Tux.ppm
    P6
    265 314
    255

Isso significa que o restante dos dados binários é de 265x314 pixels por 255 cores.

Para criar nosso pinguim (criptografado), queremos seguir os seguintes passos:
   1. separar o cabeçalho do corpo
   2. criptografar o corpo usando a ferramenta de linha de comando `openssl`
   3. combine o caceçalho original com o novo corpo criptografado
  
Isso pode ser feito com os seguintes comandos:

    head -n 4 Tux.ppm > Tux.header
    tail -n +5 Tux.ppm > Tux.body
    openssl enc -aes-128-ecb -nosalt -pass pass:"senha" -in Tux.body -out Tux.body.ecb
    cat Tux.header Tux.body.ecb > Tux.ecb.ppm
  
Então, vamos visualizar os resultados. Muitos visualizadores de imagens podem decodificar o formato PPM.
No macOS, usei o aplicativo Preview. Eu também usei esse aplicativo para salvar os resultados em
o formato PNG mais convencional (comprimido) (`Tux.ecb.png`), que você pode visualizar no navegador.
Eu deixei o formato PNG neste projeto, para exibição nesta página.

## Mudando para CBC

Conforme observado, o modo ECB ainda pode falhar em escoder a informação. 

Um modo alternativo para lidar com essa situação é conhecido como *cipher block chaining* (CBC). 

Em vez de criptografar um *bloco* com uma *chave*, você criptografa o *bloco* atual com
tanto a *chave* quanto os resultados do bloco anterior.

No exemplo a seguir, criptografamos nossa imagem com AES, mas desta vez, usando
*CBC*. Como você pode ver, agora o conteúdo do arquivo está mais complexo.
Não temos nenhuma pista aqui do que o conteúdo original poderia ter sido.

![Tux-cbc](/Tux.cbc.png)

### Testando o Modo ECB

Para alterar o modo de cifragem para *CBC*, simplemente basta mudar o algoritmo 
para *aes-128-cbc", e alterar o arquivo de saída para *Tux.body.cbc*.

    head -n 4 Tux.ppm > Tux.header
    tail -n +5 Tux.ppm > Tux.body
    openssl enc -aes-128-cbc -nosalt -pass pass:"rob" -in Tux.body -out Tux.body.cbc
    cat Tux.header Tux.body.cbc > Tux.ecb.ppm    
    
  
## Conclusão

O objetivo deste projeto é simplesmente para propósitos educacionais, 
para permitir ao discente, entender as diferenças entre os modos *ECB* e *CBC*.
