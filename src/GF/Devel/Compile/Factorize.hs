----------------------------------------------------------------------
-- |
-- Module      : OptimizeGF
-- Maintainer  : AR
-- Stability   : (stable)
-- Portability : (portable)
--
-- > CVS $Date: 2005/04/21 16:21:33 $ 
-- > CVS $Author: bringert $
-- > CVS $Revision: 1.6 $
--
-- Optimizations on GF source code: sharing, parametrization, value sets.
--
-- optimization: sharing branches in tables. AR 25\/4\/2003.
-- following advice of Josef Svenningsson
-----------------------------------------------------------------------------

module GF.Devel.Compile.Factorize (
  optModule,
  unshareModule,
  unsubexpModule,
  unoptModule,
  subexpModule,
  shareModule
  ) where 

import GF.Devel.Grammar.Grammar
import GF.Devel.Grammar.Construct
import GF.Devel.Grammar.PrGF (prt)
import qualified GF.Devel.Grammar.Macros as C

import GF.Devel.Grammar.Lookup
import GF.Infra.Ident

import GF.Data.Operations

import Control.Monad
import Data.Map (Map)
import qualified Data.Map as Map
import Data.List

optModule :: SourceModule -> SourceModule
optModule = subexpModule . shareModule

shareModule = processModule optim

unoptModule :: GF -> SourceModule -> SourceModule
unoptModule gr = unshareModule gr . unsubexpModule

unshareModule :: GF -> SourceModule -> SourceModule
unshareModule gr = processModule (const (unoptim gr))

processModule :: (Ident -> Term -> Term) -> SourceModule -> SourceModule
processModule opt (i,mo) = 
  (i, mo {mjments = Map.map (shareInfo (opt i)) (mjments mo)})

shareInfo :: (Term -> Term) -> Judgement -> Judgement
shareInfo opt ju = ju {jdef = opt (jdef ju)}

-- the function putting together optimizations
optim :: Ident -> Term -> Term
optim c = values . factor c 0

-- we need no counter to create new variable names, since variables are 
-- local to tables ----
-- factor parametric branches

factor :: Ident -> Int -> Term -> Term
factor c i t = case t of
  T _ [_] -> t
  T _ []  -> t
  T (TComp ty) cs -> 
    T (TTyped ty) $ factors i [(p, factor c (i+1) v) | (p, v) <- cs]
  _ -> C.composSafeOp (factor c i) t
 where

   factors i psvs =   -- we know psvs has at least 2 elements
     let p   = qqIdent c i
         vs' = map (mkFun p) psvs
     in if   allEqs vs'
        then mkCase p vs' 
        else psvs

   mkFun p (patt, val) = replace (C.patt2term patt) (Vr p) val

   allEqs (v:vs) = all (==v) vs

   mkCase p (v:_) = [(PV p, v)]

--- we hope this will be fresh and don't check... 

qqIdent c i = identC ("_q" ++ prt c ++ "__" ++ show i)


--  we need to replace subterms

replace :: Term -> Term -> Term -> Term
replace old new trm = case trm of
  
  -- these are the important cases, since they can correspond to patterns  
  QC _ _   | trm == old -> new
  App t ts | trm == old -> new
  App t ts              -> App (repl t) (repl ts)
  R _ | isRec && trm == old -> new
  _ -> C.composSafeOp repl trm
 where
   repl = replace old new
   isRec = case trm of
     R _ -> True
     _ -> False

-- It is very important that this is performed only after case
-- expansion since otherwise the order and number of values can
-- be incorrect. Guaranteed by the TComp flag.

values :: Term -> Term
values t = case t of
  T ty [(ps,t)]    -> T ty [(ps,values t)] -- don't destroy parametrization
  T (TComp ty)  cs -> V ty [values t | (_, t) <- cs]
  T (TTyped ty) cs -> V ty [values t | (_, t) <- cs] 
        ---- why are these left?
        ---- printing with GrammarToSource does not preserve the distinction
  _ -> C.composSafeOp values t


-- to undo the effect of factorization

unoptim :: GF -> Term -> Term
unoptim gr = unfactor gr

unfactor :: GF -> Term -> Term
unfactor gr t = case t of
  T (TTyped ty) [(PV x,u)] -> V ty [restore x v (unfac u) | v <- vals ty]
  _ -> C.composSafeOp unfac t
 where
   unfac = unfactor gr
   vals  = err error id . allParamValues gr
   restore x u t = case t of
     Vr y | y == x -> u
     _ -> C.composSafeOp (restore x u) t


----------------------------------------------------------------------

{-
This module implements a simple common subexpression elimination
 for gfc grammars, to factor out shared subterms in lin rules.
It works in three phases: 

  (1) collectSubterms collects recursively all subterms of forms table and (P x..y)
      from lin definitions (experience shows that only these forms
      tend to get shared) and counts how many times they occur
  (2) addSubexpConsts takes those subterms t that occur more than once
      and creates definitions of form "oper A''n = t" where n is a
      fresh number; notice that we assume no ids of this form are in
      scope otherwise
  (3) elimSubtermsMod goes through lins and the created opers by replacing largest
      possible subterms by the newly created identifiers

The optimization is invoked in gf by the flag i -subs.

If an application does not support GFC opers, the effect of this
optimization can be undone by the function unSubelimCanon.

The function unSubelimCanon can be used to diagnostisize how much
cse is possible in the grammar. It is used by the flag pg -printer=subs.

-}

subexpModule :: SourceModule -> SourceModule
subexpModule (m,mo) = errVal (m,mo) $ case mtype mo of
  MTAbstract -> return (m,mo)
  _ -> do
    let js = listJudgements mo
    (tree,_) <- appSTM (getSubtermsMod m js) (Map.empty,0)
    js2 <- addSubexpConsts m tree js
    return (m, mo{mjments = Map.fromList js2})

unsubexpModule :: SourceModule -> SourceModule
unsubexpModule (m,mo) = (m, mo{mjments = rebuild (mjments mo)})
  where
    unparInfo (c, ju) = case jtype ju of
      EInt 8 -> [] -- subexp-generated opers
      _ -> [(c, ju {jdef = unparTerm (jdef ju)})]
    unparTerm t = case t of
      Q _ c@(IC ('_':'A':_)) -> --- name convention of subexp opers
        maybe t (unparTerm . jdef) $ Map.lookup c (mjments mo)
      _ -> C.composSafeOp unparTerm t
    rebuild = Map.fromList . concat . map unparInfo . Map.assocs

-- implementation

type TermList = Map Term (Int,Int) -- number of occs, id
type TermM a = STM (TermList,Int) a

addSubexpConsts :: 
  Ident -> Map Term (Int,Int) -> [(Ident,Judgement)] -> Err [(Ident,Judgement)]
addSubexpConsts mo tree lins = do
  let opers = [oper id trm | (trm,(_,id)) <- list]
  mapM mkOne $ opers ++ lins
 where

   mkOne (f, def) = return (f, def {jdef = recomp f (jdef def)})
   recomp f t = case Map.lookup t tree of
     Just (_,id) | ident id /= f -> Q mo (ident id)
     _ -> C.composSafeOp (recomp f) t

   list = Map.toList tree

   oper id trm = (ident id, resOper (EInt 8) trm)
   --- impossible type encoding generated opers

getSubtermsMod :: Ident -> [(Ident,Judgement)] -> TermM (Map Term (Int,Int))
getSubtermsMod mo js = do
  mapM (getInfo (collectSubterms mo)) js
  (tree0,_) <- readSTM
  return $ Map.filter (\ (nu,_) -> nu > 1) tree0
 where
   getInfo get fi@(_,i) = do
     get (jdef i)    
     return $ fi

collectSubterms :: Ident -> Term -> TermM Term
collectSubterms mo t = case t of
  App f a -> do
    collect f
    collect a
    add t 
  T ty cs -> do
    let (_,ts) = unzip cs
    mapM collect ts
    add t
  V ty ts -> do
    mapM collect ts
    add t
----  K (KP _ _)  -> add t
  _ -> C.composOp (collectSubterms mo) t
 where
   collect = collectSubterms mo
   add t = do
     (ts,i) <- readSTM
     let 
       ((count,id),next) = case Map.lookup t ts of
         Just (nu,id) -> ((nu+1,id), i)
         _ ->            ((1,   i ), i+1)
     writeSTM (Map.insert t (count,id) ts, next)
     return t --- only because of composOp

ident :: Int -> Ident
ident i = identC ("_A" ++ show i) ---

