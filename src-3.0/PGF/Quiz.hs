----------------------------------------------------------------------
-- |
-- Module      : TeachYourself
-- Maintainer  : AR
-- Stability   : (stable)
-- Portability : (portable)
--
-- > CVS $Date: 2005/04/21 16:46:13 $ 
-- > CVS $Author: bringert $
-- > CVS $Revision: 1.7 $
--
-- translation and morphology quiz. AR 10\/5\/2000 -- 12\/4\/2002 -- 14\/6\/2008
--------------------------------------------------------------------------------

module PGF.Quiz (
  translationQuiz,
  translationList,
  morphologyQuiz,
  morphologyList
  ) where

import PGF
import PGF.ShowLinearize

import GF.Data.Operations
import GF.Infra.UseIO

import System.Random

import Data.List (nub)

-- translation and morphology quiz. AR 10/5/2000 -- 12/4/2002

translationQuiz :: PGF -> Language -> Language -> Category -> IO ()
translationQuiz pgf ig og cat = do
  tts <- translationList pgf ig og cat infinity
  let qas = [ (q, mkAnswer as) | (q,as) <- tts]
  teachDialogue qas "Welcome to GF Translation Quiz."

translationList :: PGF -> Language -> Language -> Category -> Int -> IO [(String,[String])]
translationList pgf ig og cat number = do
  ts <- generateRandom pgf cat >>= return . take number
  return $ map mkOne $ ts
 where
   mkOne t = (norml (linearize pgf ig t), map (norml . linearize pgf og) (homonyms t))
   homonyms = nub . parse pgf ig cat . linearize pgf ig

morphologyQuiz :: PGF -> Language -> Category -> IO ()
morphologyQuiz pgf ig cat = do
  tts <- morphologyList pgf ig cat infinity
  let qas = [ (q, mkAnswer as) | (q,as) <- tts]
  teachDialogue qas "Welcome to GF Morphology Quiz."

morphologyList :: PGF -> Language -> Category -> Int -> IO [(String,[String])]
morphologyList pgf ig cat number = do
  ts  <- generateRandom pgf cat >>= return . take (max 1 number)
  gen <- newStdGen
  let ss    = map (tabularLinearize pgf (mkCId ig)) ts
  let size  = length (head ss)
  let forms = take number $ randomRs (0,size-1) gen
  return [(head (snd (head pws)) +++ par, ws) | 
           (pws,i) <- zip ss forms, let (par,ws) = pws !! i]

-- | compare answer to the list of right answers, increase score and give feedback 
mkAnswer :: [String] -> String -> (Integer, String) 
mkAnswer as s = if (elem (norml s) as) 
                   then (1,"Yes.") 
                   else (0,"No, not" +++ s ++ ", but" ++++ unlines as)

norml :: String -> String
norml = unwords . words

-- | the maximal number of precompiled quiz problems
infinity :: Int
infinity = 256

