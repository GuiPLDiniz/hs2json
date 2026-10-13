
module Main where

import SimpleJSON

main :: IO ()
main = do
  let nome = JString "Ana"
  let idade = JNumber 22
  let ativo = JBool True
  let vazio = JNull

  putStrLn "Testando accessors JSON:"

  print (getString nome)
  print (getInt idade)
  print (getDouble idade)
  print (getBool ativo)
  print (isNull vazio)

  putStrLn "Testando tipo incorreto:"
  print (getString idade)
