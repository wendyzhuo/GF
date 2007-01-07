----------------------------------------------------------------------
-- |
-- Module      : PrJSGF
-- Maintainer  : BB
-- Stability   : (stable)
-- Portability : (portable)
--
-- > CVS $Date: 2005/11/01 20:09:04 $ 
-- > CVS $Author: bringert $
-- > CVS $Revision: 1.16 $
--
-- This module prints a CFG as a JSGF grammar.
--
-- FIXME: remove \/ warn \/ fail if there are int \/ string literal
-- categories in the grammar
--
-- FIXME: convert to UTF-8
-----------------------------------------------------------------------------

module GF.Speech.PrJSGF (jsgfPrinter) where

import GF.Conversion.Types
import GF.Data.Utilities
import GF.Formalism.CFG
import GF.Formalism.Utilities (Symbol(..), NameProfile(..), Profile(..), filterCats)
import GF.Infra.Ident
import GF.Infra.Print
import GF.Infra.Option
import GF.Probabilistic.Probabilistic (Probs)
import GF.Speech.SISR
import GF.Speech.SRG
import GF.Speech.RegExp
import GF.Compile.ShellState (StateGrammar)

import Data.Char
import Data.List
import Text.PrettyPrint.HughesPJ
import Debug.Trace


jsgfPrinter :: Maybe SISRFormat
	    -> Options 
            -> StateGrammar -> String
jsgfPrinter sisr opts s = show $ prJSGF sisr $ makeSimpleSRG opts s

prJSGF :: Maybe SISRFormat -> SRG -> Doc
prJSGF sisr srg@(SRG{grammarName=name,startCat=start,origStartCat=origStart,rules=rs})
    = header $++$ mainCat $++$ vcat topCatRules $++$ foldr ($++$) empty (map prRule rs)
    where
    header = text "#JSGF V1.0 UTF-8;" $$
             comment ("JSGF speech recognition grammar for " ++ name) $$
             comment "Generated by GF" $$
	     text ("grammar " ++ name ++ ";") 
    mainCat = comment ("Start category: " ++ origStart) $$
	      rule True "MAIN" [prCat start]
    prRule (SRGRule cat origCat rhs) = 
	comment origCat $$
        rule False cat (map prAlt (ebnfSRGAlts rhs))
--        rule False cat (map prAlt rhs)
    -- FIXME: use the probability
    prAlt (EBnfSRGAlt mp n rhs) = sep [initTag, prItem sisr n rhs, finalTag]
--    prAlt (SRGAlt mp n rhs) = initTag <+> prItem sisr n rhs <+> finalTag
      where initTag | isEmpty t = empty
                    | otherwise = text "<NULL>" <+>  t
                where t = tag sisr (profileInitSISR n)
            finalTag = tag sisr (profileFinalSISR n)

    topCatRules = [rule True (catFormId tc) (map (it tc) cs) | (tc,cs) <- srgTopCats srg]
        where it i c = prCat c <+> tag sisr (topCatSISR c)

catFormId :: String -> String
catFormId = (++ "_cat")

prCat :: SRGCat -> Doc
prCat c = char '<' <> text c <> char '>'

prItem :: Maybe SISRFormat -> CFTerm -> EBnfSRGItem -> Doc
prItem sisr t = f 1
  where
    f _ (REUnion [])  = text "<VOID>"
    f p (REUnion xs) 
        | not (null es) = brackets (f 0 (REUnion nes))
        | otherwise = (if p >= 1 then parens else id) (alts (map (f 1) xs))
      where (es,nes) = partition isEpsilon xs
    f _ (REConcat []) = text "<NULL>"
    f p (REConcat xs) = (if p >= 3 then parens else id) (hsep (map (f 2) xs))
    f p (RERepeat x)  = f 3 x <> char '*'
    f _ (RESymbol s)  = prSymbol sisr t s

{-
prItem :: Maybe SISRFormat -> CFTerm -> [Symbol SRGNT Token] -> Doc
prItem _ _ [] = text "<NULL>"
prItem sisr cn ss = paren $ hsep $ map (prSymbol sisr cn) ss
  where paren = if length ss == 1 then id else parens
-}

prSymbol :: Maybe SISRFormat -> CFTerm -> Symbol SRGNT Token -> Doc
prSymbol sisr cn (Cat n@(c,_)) = prCat c <+> tag sisr (catSISR cn n)
prSymbol _ cn (Tok t) | all isPunct (prt t) = empty  -- removes punctuation
                      | otherwise = text (prt t) -- FIXME: quote if there is whitespace or odd chars

tag :: Maybe SISRFormat -> (SISRFormat -> SISRTag) -> Doc
tag Nothing _ = empty
tag (Just fmt) t = case t fmt of
                     [] -> empty
                     ts -> char '{' <+> (text (e $ prSISR ts)) <+> char '}'
  where e [] = []
        e ('}':xs) = '\\':'}':e xs
        e ('\n':xs) = ' ' : e (dropWhile isSpace xs)
        e (x:xs) = x:e xs

isPunct :: Char -> Bool
isPunct c = c `elem` "-_.;.,?!"

comment :: String -> Doc
comment s = text "//" <+> text s

alts :: [Doc] -> Doc
alts = sep . prepunctuate (text "| ")

rule :: Bool -> SRGCat -> [Doc] -> Doc
rule pub c xs = sep [p <+> prCat c <+> char '=', nest 2 (alts xs) <+> char ';']
  where p = if pub then text "public" else empty

-- Pretty-printing utilities

emptyLine :: Doc
emptyLine = text ""

prepunctuate :: Doc -> [Doc] -> [Doc]
prepunctuate _ [] = []
prepunctuate p (x:xs) = x : map (p <>) xs

($++$) :: Doc -> Doc -> Doc
x $++$ y = x $$ emptyLine $$ y

