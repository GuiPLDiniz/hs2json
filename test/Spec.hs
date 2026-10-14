{-# OPTIONS_GHC -Wno-orphans #-}
module Main where

import Test.QuickCheck
import SimpleJSON

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
prop_geradorFunciona :: JValue -> Bool
prop_geradorFunciona _ = True

main :: IO ()
main = quickCheck prop_geradorFunciona
