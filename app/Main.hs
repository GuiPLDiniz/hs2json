
module Main where

import SimpleJSON

main :: IO ()
main = do
  let pessoa = JObject
        [ ("nome", JString "Ana")
        , ("idade", JNumber 22)
        , ("ativo", JBool True)
        ]
  
  print pessoa
