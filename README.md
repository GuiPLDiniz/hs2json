# hs2json — Biblioteca JSON em Haskell

Projeto desenvolvido para a Avaliação da Unidade 2 da disciplina de programação em Haskell.

## Objetivo

Implementar uma biblioteca Haskell para representar valores JSON, extrair dados de maneira segura e produzir documentos JSON formatados, utilizando Cabal e testes baseados em propriedades com QuickCheck.

O desenvolvimento foi baseado no tutorial [Construindo e Testando uma Biblioteca Haskell](https://lambdageo-edu.github.io/lambdageo-tutorials/haskell/).

## Tecnologias utilizadas

- GHC 9.10.3
- Cabal 3.16.1.0
- Haskell2010
- QuickCheck 2.19.0.0
- Git e GitHub

## Estrutura do projeto

- `src/SimpleJSON.hs`: definição do tipo algébrico `JValue` e funções seguras de extração.
- `src/Prettify.hs`: representação abstrata de documentos (`Doc`) e funções de renderização.
- `src/PrettyJSON.hs`: conversão de valores JSON em documentos, incluindo tratamento de caracteres especiais e Unicode.
- `app/Main.hs`: demonstração da biblioteca.
- `test/Spec.hs`: gerador `Arbitrary JValue` e testes automatizados com QuickCheck.
- `hs2json.cabal`: configuração da biblioteca, do executável e dos testes.

## Compilação e execução

Com GHC e Cabal instalados, acessar o diretório do projeto.

**Compilar:**

```powershell
cabal build
```

**Executar:**

```powershell
cabal run
```

**Executar os testes:**

```powershell
cabal test --test-show-details=direct
```

O executável demonstra a representação de objetos JSON, sua renderização compacta e formatada e o tratamento de escapes em strings.

## Testes com QuickCheck

A suíte contém 12 verificações, abrangendo:

1. Extração de strings (`getString`).
2. Extração de inteiros (`getInt`).
3. Extração de booleanos (`getBool`).
4. Extração de arrays (`getArray`).
5. Identificação de valores nulos (`isNull`).
6. Extração de objetos (`getObject`).
7. Renderização de booleanos.
8. Escapes de strings.
9. Tratamento de números não finitos.
10. Arrays e objetos vazios.
11. Caracteres Unicode.
12. Estruturas JSON aninhadas.

O gerador utiliza `sized` e `resize (n div 2)` para limitar o crescimento das estruturas recursivas.

A suíte utiliza `quickCheckResult` e `exitFailure`, permitindo que o Cabal identifique falhas de teste.

## Validação adicional

O objeto JSON compacto produzido pelo executável foi validado com o parser JSON do Python 3.14, que aceitou sua sintaxe.

Essa verificação complementa os testes automatizados, mas não constitui prova de validade para todos os valores possíveis.

## Dificuldades encontradas

Durante o desenvolvimento, foram identificados e corrigidos problemas relacionados a:

- Substituição do módulo inicial `MyLib` por `SimpleJSON`.
- Conflitos e duplicações na implementação do renderizador.
- Tratamento do construtor `Nest` nas funções de renderização.
- Indentação de objetos e arrays.
- Avisos do compilador nos testes.
- Controle da geração recursiva com QuickCheck.
- Reconhecimento de falhas pelos testes Cabal.

## Histórico de desenvolvimento

O projeto utiliza commits incrementais com mensagens descritivas, seguindo o padrão *Conventional Commits*.


## Vídeo de apresentação

**Link do vídeo:** [Apresentação do projeto hs2json](https://drive.google.com/drive/folders/1y0xNQTF0xSoBpFHXQEK01G0a6zMvqIba?usp=sharing)



## Referências

- [Tutorial oficial utilizado no trabalho](https://lambdageo-edu.github.io/lambdageo-tutorials/haskell/)
- [Documentação do Cabal](https://www.haskell.org/cabal/)
- [QuickCheck](https://hackage.haskell.org/package/QuickCheck)
- [RFC 8259 — The JavaScript Object Notation (JSON) Data Interchange Format](https://www.rfc-editor.org/rfc/rfc8259)

## Autor

Guilherme Pessôa Lima Diniz — [GitHub](https://github.com/GuiPLDiniz)