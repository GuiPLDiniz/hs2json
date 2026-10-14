
module PrettyJSON
  ( renderJValue
  ) where

import Prelude hiding ((<>))
import Data.Bits (shiftR, (.&.))
import Data.Char (ord)
import Numeric (showHex)

import SimpleJSON (JValue(..))
import Prettify
  ( Doc, (<>), char, double, fsep
  , hcat, punctuate, text, nest, line, group
  )

-- Converte um valor JSON em documento
renderJValue :: JValue -> Doc
renderJValue (JString s) = string s
renderJValue (JNumber n) = double n
renderJValue (JBool True) = text "true"
renderJValue (JBool False) = text "false"
renderJValue JNull = text "null"

renderJValue (JArray values) =
  series '[' ']' renderJValue values

renderJValue (JObject fields) =
  series '{' '}' field fields
  where
    field (name, value) =
      string name <> text ": " <> renderJValue value

-- Formata uma string JSON entre aspas
string :: String -> Doc
string = enclose '"' '"' . hcat . map oneChar

-- Adiciona os delimitadores
enclose :: Char -> Char -> Doc -> Doc
enclose left right doc =
  char left <> doc <> char right

-- Escapa caracteres especiais
oneChar :: Char -> Doc
oneChar c =
  case lookup c simpleEscapes of
    Just escaped -> text escaped
    Nothing
      | mustEscape c -> hexEscape c
      | otherwise    -> char c
  where
    mustEscape ch =
      ch < ' ' || ch == '\x7f' || ch > '\xff'

-- Escapes simples reconhecidos pelo JSON
simpleEscapes :: [(Char, String)]
simpleEscapes =
  zipWith makeEscape "\b\n\f\r\t\\\"/" "bnfrt\\\"/"
  where
    makeEscape a b = (a, ['\\', b])

-- Representacao Unicode com quatro digitos
smallHex :: Int -> Doc
smallHex n =
  text "\\u"
  <> text (replicate (4 - length hex) '0')
  <> text hex
  where
    hex = showHex n ""

-- Caracteres acima de U+FFFF
astral :: Int -> Doc
astral n =
  smallHex (high + 0xd800)
  <> smallHex (low + 0xdc00)
  where
    high = (n `shiftR` 10) .&. 0x3ff
    low  = n .&. 0x3ff

-- Escolhe a forma de escape Unicode
hexEscape :: Char -> Doc
hexEscape c
  | code < 0x10000 = smallHex code
  | otherwise      = astral (code - 0x10000)
  where
    code = ord c

-- Formata arrays e objetos

series :: Char -> Char -> (a -> Doc) -> [a] -> Doc
series open close _ [] =
  char open <> char close

series open close renderItem items =
  group $
    char open
    <> nest 2
         (line <> fsep (punctuate (char ',') (map renderItem items)))
    <> line
    <> char close

