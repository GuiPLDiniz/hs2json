{-# OPTIONS_GHC -Wno-orphans #-}
module Main where

import Test.QuickCheck
import SimpleJSON
import PrettyJSON (renderJValue)
import Prettify (compact)
import System.Exit (exitFailure)

-- Gera valores JSON aleatorios
instance Arbitrary JValue where
  arbitrary = sized gerarJSON

-- Gerador recursivo com controle de tamanho
gerarJSON :: Int -> Gen JValue
gerarJSON n
  | n <= 0 = gerarSimples
  | otherwise =
      frequency
        [ (5, gerarSimples)
        , (1, gerarArray)
        , (1, gerarObjeto)
        ]
  where
    tamanho = n `div` 2

    gerarArray =
      JArray <$> resize tamanho
        (listOf (gerarJSON tamanho))

    gerarObjeto =
      JObject <$> resize tamanho
        (listOf gerarCampo)

    gerarCampo = do
      chave <- resize tamanho arbitrary
      valor <- gerarJSON tamanho
      return (chave, valor)

-- Gera valores JSON nao recursivos
gerarSimples :: Gen JValue
gerarSimples =
  oneof
    [ JString <$> arbitrary
    , JNumber <$> escolherNumero
    , JBool <$> arbitrary
    , return JNull
    ]

-- Evita NaN e Infinity
escolherNumero :: Gen Double
escolherNumero =
  choose (-1000000, 1000000)

-- Teste inicial do gerador

-- Propriedade 1: extracao de strings
prop_getString :: String -> Bool
prop_getString s =
  getString (JString s) == Just s



-- Propriedade 2: extracao de inteiros
prop_getInt :: Int -> Bool
prop_getInt n =
  getInt (JNumber numero) ==
    if toInteger (truncate numero :: Integer) == toInteger n
    then Just n
    else Nothing
  where
    numero = fromIntegral n :: Double


-- Verifica a extracao de numeros Double
prop_getDouble :: Double -> Property
prop_getDouble n =
  not (isNaN n || isInfinite n) ==>
    getDouble (JNumber n) === Just n



-- Propriedade 3: extracao de booleanos
prop_getBool :: Bool -> Bool
prop_getBool b =
  getBool (JBool b) == Just b

-- Propriedade 4: extracao de arrays
prop_getArray :: [JValue] -> Bool
prop_getArray xs =
  getArray (JArray xs) == Just xs

-- Propriedade 5: identificacao de nulos
prop_isNull :: JValue -> Bool
prop_isNull value =
  isNull value == (value == JNull)

-- Propriedade 6: extracao de objetos
prop_getObject :: [(String, JValue)] -> Bool
prop_getObject campos =
  getObject (JObject campos) == Just campos

-- Propriedade 7: renderizacao de booleanos
prop_renderBool :: Bool -> Bool
prop_renderBool b =
  compact (renderJValue (JBool b)) ==
    if b then "true" else "false"


-- Propriedade 8: escapes de strings JSON
prop_escapeString :: String -> Bool
prop_escapeString s =
  case compact (renderJValue (JString s)) of
    '"' : resto ->
      case reverse resto of
        '"' : conteudoReverso ->
          all (/= '\n') conteudoReverso
          && all (/= '\t') conteudoReverso
        _ -> False
    _ -> False


-- Valores numericos especiais nao podem aparecer no JSON
prop_numerosEspeciais :: Bool
prop_numerosEspeciais =
  compact (renderJValue (JNumber (0 / 0))) == "null"
  && compact (renderJValue (JNumber (1 / 0))) == "null"
  && compact (renderJValue (JNumber ((-1) / 0))) == "null"

-- Arrays e objetos vazios
prop_estruturasVazias :: Bool
prop_estruturasVazias =
  compact (renderJValue (JArray [])) == "[]"
  && compact (renderJValue (JObject [])) == "{}"



-- Verifica escapes Unicode
prop_unicode :: Bool
prop_unicode =
  compact (renderJValue (JString "\x1F600"))
    == "\"\\ud83d\\ude00\""
  && compact (renderJValue (JString "\x00E7"))
    == "\"\x00E7\""
  && compact (renderJValue (JString "\n"))
    == "\"\\n\""


-- Verifica estruturas JSON aninhadas
prop_estruturasAninhadas :: Bool
prop_estruturasAninhadas =
  let documento =
        JObject
          [ ("usuario", JObject
              [ ("nome", JString "Ana")
              , ("ativo", JBool True)
              ])
          , ("numeros", JArray
              [ JNumber 1
              , JNumber 2
              , JNumber 3
              ])
          ]

      resultado = compact (renderJValue documento)

  in resultado ==
       "{\"usuario\": {\"nome\": \"Ana\",\"ativo\": true},\"numeros\": [1.0,2.0,3.0]}"



-- Verifica escapes obrigatorios de caracteres JSON
prop_escapesEspeciais :: Bool
prop_escapesEspeciais =
  and
    [ confere "\"" "\\\""
    , confere "\\" "\\\\"
    , confere "\n" "\\n"
    , confere "\t" "\\t"
    , confere "\x0001" "\\u0001"
    ]
  where
    confere original esperado =
      compact (renderJValue (JString original))
        == "\"" ++ esperado ++ "\""







main :: IO ()
main = do
  resultados <- sequence
    [ executar "getString" prop_getString
    , executar "getInt" prop_getInt
    , executar "getBool" prop_getBool
    , executar "getArray" prop_getArray
    , executar "isNull" prop_isNull
    , executar "getObject" prop_getObject
    , executar "renderBool" prop_renderBool
    , executar "escapeString" prop_escapeString
    , executar "numerosEspeciais" prop_numerosEspeciais
    , executar "estruturasVazias" prop_estruturasVazias
    , executar "unicode" prop_unicode
    , executar "estruturasAninhadas" prop_estruturasAninhadas
    , executar "getDouble" prop_getDouble
    , executar "escapesEspeciais" prop_escapesEspeciais
    ]

  if and resultados
    then putStrLn "\nTodos os testes passaram!"
    else do
      putStrLn "\nExistem testes com falha!"
      exitFailure

executar :: Testable prop => String -> prop -> IO Bool
executar nome propriedade = do
  putStrLn ("\nTeste - " ++ nome)
  resultado <- quickCheckResult propriedade
  return (isSuccess resultado)
