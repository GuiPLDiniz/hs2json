
module Prettify
  ( Doc
  , empty
  , char
  , text
  , double
  , line
  , (<>)
  , hcat
  , fsep
  , punctuate
  , compact
  , pretty
  , nest
  , group
  ) where

import Prelude hiding ((<>))

-- Representacao abstrata de um documento
data Doc
  = Empty
  | Char Char
  | Text String
  | Line
  | Concat Doc Doc
  | Union Doc Doc
  | Nest Int Doc
  deriving (Show, Eq)

-- Documento vazio
empty :: Doc
empty = Empty

-- Documento contendo um caractere
char :: Char -> Doc
char c = Char c

-- Documento contendo texto
text :: String -> Doc
text "" = Empty
text s  = Text s

-- Representacao textual de um numero
double :: Double -> Doc
double d = text (show d)

-- Quebra de linha
line :: Doc
line = Line

nest :: Int -> Doc -> Doc
nest n doc = Nest n doc

-- Concatenacao de documentos
(<>) :: Doc -> Doc -> Doc
Empty <> y = y
x <> Empty = x
x <> y     = Concat x y

-- Concatenacao de uma lista de documentos
hcat :: [Doc] -> Doc
hcat = foldr (<>) empty

-- Converte um documento em texto


compact :: Doc -> String
compact doc = transform [doc]
  where
    transform [] = ""
    transform (d:ds) =
      case d of
        Empty        -> transform ds
        Char c       -> c : transform ds
        Text s       -> s ++ transform ds
        Line         -> transform ds
        Concat a b   -> transform (a:b:ds)
        Union _ b    -> transform (b:ds)
        Nest _ x     -> transform (x:ds)



-- Junta documentos utilizando separadores flexiveis
fsep :: [Doc] -> Doc
fsep = foldr (</>) empty

-- Adiciona um separador entre documentos
punctuate :: Doc -> [Doc] -> [Doc]
punctuate _ []     = []
punctuate _ [d]    = [d]
punctuate p (d:ds) = (d <> p) : punctuate p ds

-- Concatenacao com possibilidade de quebra de linha
(</>) :: Doc -> Doc -> Doc
x </> y = x <> softline <> y

-- Permite escolher entre espaco e quebra de linha
softline :: Doc
softline = group line

-- Agrupa alternativas de formatacao
group :: Doc -> Doc
group x = Union (flatten x) x

-- Substitui quebras de linha por espacos
flatten :: Doc -> Doc
flatten Empty        = Empty
flatten (Char c)     = Char c
flatten (Text s)     = Text s
flatten Line         = Char ' '
flatten (Concat x y) = Concat (flatten x) (flatten y)
flatten (Union x _)  = flatten x
flatten (Nest n x) = Nest n (flatten x)


-- Renderiza um documento respeitando a largura
-- e a indentacao
pretty :: Int -> Doc -> String
pretty width doc = best 0 [(0, doc)]
  where
    best _ [] = ""
    best col ((indent, d):ds) =
      case d of
        Empty -> best col ds
        Char c -> c : best (col + 1) ds
        Text s -> s ++ best (col + length s) ds
        Line ->
          '\n' : replicate indent ' '
          ++ best indent ds
        Concat a b ->
          best col ((indent, a):(indent, b):ds)
        Union a b ->
          nicest col
            (best col ((indent, a):ds))
            (best col ((indent, b):ds))
        Nest n x ->
          best col ((indent + n, x):ds)

    nicest col a b
      | fits (width - col) a = a
      | otherwise            = b

    fits w _ | w < 0 = False
    fits _ "" = True
    fits _ ('\n':_) = True
    fits w (_:cs) = fits (w - 1) cs
