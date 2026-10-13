
module Main where

import Prelude hiding ((<>))
import Prettify

main :: IO ()
main = do
  let documento =
        text "Haskell" <> char ' ' <> text "JSON"

  putStrLn "Teste 1 - Compact:"
  putStrLn (compact documento)

  putStrLn "\nTeste 2 - Pretty:"
  putStrLn (pretty 80 documento)

  let lista =
        fsep
          [ text "Haskell"
          , text "permite"
          , text "formatar"
          , text "documentos"
          ]

  putStrLn "\nTeste 3 - Largura 80:"
  putStrLn (pretty 80 lista)

  putStrLn "\nTeste 4 - Largura 15:"
  putStrLn (pretty 15 lista)
