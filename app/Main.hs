
module Main where

import SimpleJSON
import PrettyJSON
import Prettify (pretty, compact)

main :: IO ()
main = do
  let pessoa = JObject
        [ ("nome", JString "Ana")
        , ("idade", JNumber 22)
        , ("ativo", JBool True)
        , ("cidade", JString "Sao Luis")
        , ("telefones", JArray
            [ JString "99999-1111"
            , JString "98888-2222"
            ])
        ]

  putStrLn "=== JSON compacto ==="
  putStrLn (compact (renderJValue pessoa))

  putStrLn "\n=== JSON formatado ==="
  putStrLn (pretty 40 (renderJValue pessoa))

  putStrLn "\n=== Teste de escapes ==="
  let mensagem = JString "Linha 1\nLinha 2\t\"teste\""
  putStrLn (compact (renderJValue mensagem))
