-- This Happy file was machine-generated by the BNF converter
{
{-# OPTIONS -fno-warn-incomplete-patterns -fno-warn-overlapping-patterns #-}
module GF.GFCC.Raw.ParGFCCRaw (parseGrammar) where
import GF.GFCC.Raw.AbsGFCCRaw
import GF.GFCC.Raw.LexGFCCRaw
import GF.GFCC.Raw.ErrM
}

%name pGrammar Grammar
%name pRExp RExp
%name pListRExp ListRExp

-- no lexer declaration
%monad { Err } { thenM } { returnM }
%tokentype { Token }

%token 
 '(' { PT _ (TS "(") }
 ')' { PT _ (TS ")") }
 '?' { PT _ (TS "?") }

L_integ  { PT _ (TI $$) }
L_quoted { PT _ (TL $$) }
L_doubl  { PT _ (TD $$) }
L_CId { PT _ (T_CId $$) }
L_err    { _ }


%%

Integer :: { Integer } : L_integ  { (read $1) :: Integer }
String  :: { String }  : L_quoted { $1 }
Double  :: { Double }  : L_doubl  { (read $1) :: Double }
CId    :: { CId} : L_CId { CId ($1)}

Grammar :: { Grammar }
Grammar : ListRExp { Grm (reverse $1) } 


RExp :: { RExp }
RExp : '(' CId ListRExp ')' { App $2 (reverse $3) } 
  | CId { AId $1 }
  | Integer { AInt $1 }
  | String { AStr $1 }
  | Double { AFlt $1 }
  | '?' { AMet }


ListRExp :: { [RExp] }
ListRExp : {- empty -} { [] } 
  | ListRExp RExp { flip (:) $1 $2 }



{

parseGrammar :: String -> IO Grammar
parseGrammar f = case pGrammar (myLexer f) of
  Ok g -> return g
  Bad s -> error s

returnM :: a -> Err a
returnM = return

thenM :: Err a -> (a -> Err b) -> Err b
thenM = (>>=)

happyError :: [Token] -> Err a
happyError ts =
  Bad $ "syntax error at " ++ tokenPos ts ++ 
  case ts of
    [] -> []
    [Err _] -> " due to lexer error"
    _ -> " before " ++ unwords (map prToken (take 4 ts))

myLexer = tokens
}

