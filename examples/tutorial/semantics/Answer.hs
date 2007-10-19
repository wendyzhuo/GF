module Main where

import GSyntax
import AnswerBase
import GF.GFCC.API

main :: IO ()
main = do
  gr <- file2grammar "base.gfcc"
  loop gr

loop :: MultiGrammar -> IO ()
loop gr = do
  s <- getLine
  let t:_ = parse gr "BaseEng" "S" s
  putStrLn $ showTree t
  let p = iS $ fg t
  putStrLn $ show p
  loop gr

