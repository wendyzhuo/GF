----------------------------------------------------------------------
-- |
-- Module      : Optimize
-- Maintainer  : AR
-- Stability   : (stable)
-- Portability : (portable)
--
-- > CVS $Date: 2005/09/16 13:56:13 $ 
-- > CVS $Author: aarne $
-- > CVS $Revision: 1.18 $
--
-- Top-level partial evaluation for GF source modules.
-----------------------------------------------------------------------------

module GF.Devel.Compile.Optimize (optimizeModule) where

import GF.Devel.Grammar.Grammar
import GF.Devel.Grammar.Construct
import GF.Devel.Grammar.Macros
--import GF.Devel.Grammar.PrGF
import GF.Devel.Grammar.Compute

--import GF.Infra.Ident

--import GF.Grammar.Lookup
--import GF.Grammar.Refresh

--import GF.Compile.BackOpt
--import GF.Devel.CheckGrammar
--import GF.Compile.Update


--import GF.Infra.CheckM
import GF.Infra.Option ----

import GF.Data.Operations

import Control.Monad
import Data.List

import Debug.Trace


optimizeModule :: Options -> GF -> SourceModule -> Err SourceModule
optimizeModule opts gf sm@(m,mo) = case mtype mo of
  MTConcrete _ -> opt sm 
  MTInstance _ -> opt sm
  MTGrammar   -> opt sm
  _ -> return sm
 where
   opt (m,mo) = do
     mo' <- termOpModule (computeTerm gf) mo
     return (m,mo')



{-

-- conditional trace

prtIf :: (Print a) => Bool -> a -> a
prtIf b t = if b then trace (" " ++ prt t) t else t

-- | partial evaluation of concrete syntax. 
-- AR 6\/2001 -- 16\/5\/2003 -- 5\/2\/2005 -- 7/12/2007

type EEnv = () --- not used

-- only do this for resource: concrete is optimized in gfc form



 =mse@(ms,eenv) mo@(_,mi) = case mi of
  ModMod m0@(Module mt st fs me ops js) | 
    st == MSComplete && isModRes m0 && not (oElem oEval oopts)-> do
      (mo1,_) <- evalModule oopts mse mo
      let 
       mo2 = case optim of
        "parametrize" -> shareModule paramOpt mo1  -- parametrization and sharing
        "values"      -> shareModule valOpt mo1    -- tables as courses-of-values
        "share"       -> shareModule shareOpt mo1  -- sharing of branches
        "all"         -> shareModule allOpt mo1    -- first parametrize then values
        "none"        -> mo1                       -- no optimization
        _             -> mo1                       -- none; default for src
      return (mo2,eenv)
  _ -> evalModule oopts mse mo
 where
   oopts = addOptions opts (iOpts (flagsModule mo))
   optim = maybe "all" id $ getOptVal oopts useOptimizer

evalModule :: Options -> ([(Ident,SourceModInfo)],EEnv) -> (Ident,SourceModInfo) -> 
               Err ((Ident,SourceModInfo),EEnv)
evalModule oopts (ms,eenv) mo@(name,mod) = case mod of

  ModMod m0@(Module mt st fs me ops js) | st == MSComplete -> case mt of
    _ | isModRes m0 && not (oElem oEval oopts) -> do
      let deps = allOperDependencies name js
      ids <- topoSortOpers deps
      MGrammar (mod' : _) <- foldM evalOp gr ids
      return $ (mod',eenv)

    MTConcrete a -> do
      js' <- mapMTree (evalCncInfo oopts gr name a) js ---- <- gr0 6/12/2005
      return $ ((name, ModMod (Module mt st fs me ops js')),eenv)

    _ -> return $ ((name,mod),eenv)
  _ -> return $ ((name,mod),eenv)
 where
   gr0 = MGrammar $ ms
   gr  = MGrammar $ (name,mod) : ms

   evalOp g@(MGrammar ((_, ModMod m) : _)) i = do
     info  <- lookupTree prt i $ jments m
     info' <- evalResInfo oopts gr (i,info)
     return $ updateRes g name i info'

-- | only operations need be compiled in a resource, and this is local to each
-- definition since the module is traversed in topological order
evalResInfo :: Options -> SourceGrammar -> (Ident,Info) -> Err Info
evalResInfo oopts gr (c,info) = case info of

  ResOper pty pde -> eIn "operation" $ do
    pde' <- case pde of
       Yes de | optres -> liftM yes $ comp de 
       _ -> return pde
    return $ ResOper pty pde'

  _ ->  return info
 where
   comp = if optres then computeConcrete gr else computeConcreteRec gr
   eIn cat = errIn ("Error optimizing" +++ cat +++ prt c +++ ":")
   optim = maybe "all" id $ getOptVal oopts useOptimizer
   optres = case optim of
     "noexpand" -> False
     _ -> True


evalCncInfo :: 
  Options -> SourceGrammar -> Ident -> Ident -> (Ident,Info) -> Err (Ident,Info)
evalCncInfo opts gr cnc abs (c,info) = do

 seq (prtIf (oElem beVerbose opts) c) $ return ()

 errIn ("optimizing" +++ prt c) $ case info of

  CncCat ptyp pde ppr -> do
    pde' <- case (ptyp,pde) of
      (Yes typ, Yes de) -> 
        liftM yes $ pEval ([(strVar, typeStr)], typ) de
      (Yes typ, Nope)   -> 
        liftM yes $ mkLinDefault gr typ >>= partEval noOptions gr ([(strVar, typeStr)],typ)
      (May b, Nope) ->
        return $ May b
      _ -> return pde   -- indirection

    ppr' <- liftM yes $ evalPrintname gr c ppr (yes $ K $ prt c)

    return (c, CncCat ptyp pde' ppr')

  CncFun (mt@(Just (_,ty@(cont,val)))) pde ppr -> 
       eIn ("linearization in type" +++ prt (mkProd (cont,val,[])) ++++ "of function") $ do
    pde' <- case pde of
      Yes de | notNewEval -> do
        liftM yes $ pEval ty de

      _ -> return pde
    ppr' <-  liftM yes $ evalPrintname gr c ppr pde'
    return $ (c, CncFun mt pde' ppr') -- only cat in type actually needed

  _ ->  return (c,info)
 where
   pEval = partEval opts gr
   eIn cat = errIn ("Error optimizing" +++ cat +++ prt c +++ ":")
   notNewEval = not (oElem oEval opts)

-- | the main function for compiling linearizations
partEval :: Options -> SourceGrammar -> (Context,Type) -> Term -> Err Term
partEval opts gr (context, val) trm = errIn ("parteval" +++ prt_ trm) $ do
  let vars  = map fst context
      args  = map Vr vars
      subst = [(v, Vr v) | v <- vars]
      trm1  = mkApp trm args
  trm3 <- if globalTable 
             then etaExpand subst trm1 >>= outCase subst
             else etaExpand subst trm1
  return $ mkAbs vars trm3

 where 

   globalTable = oElem showAll opts --- i -all

   comp g t = ---- refreshTerm t >>= 
              computeTerm gr g t

   etaExpand su t = do
     t' <- comp su t 
     case t' of
       R _ | rightType t' -> comp su t' --- return t' wo noexpand...
       _ -> recordExpand val t' >>= comp su
   -- don't eta expand records of right length (correct by type checking)
   rightType t = case (t,val) of
     (R rs, RecType ts) -> length rs == length ts
     _ -> False

   outCase subst t = do
     pts <- getParams context
     let (args,ptyps) = unzip $ filter (flip occur t . fst) pts
     if null args 
       then return t 
       else do 
         let argtyp = RecType $ tuple2recordType ptyps
         let pvars = map (Vr . zIdent . prt) args -- gets eliminated
         patt <- term2patt $ R $ tuple2record $ pvars
         let t' = replace (zip args pvars) t
         t1 <- comp subst $ T (TTyped argtyp) [(patt, t')]
         return $ S t1 $ R $ tuple2record args

   --- notice: this assumes that all lin types follow the "old JFP style" 
   getParams = liftM concat . mapM getParam 
   getParam (argv,RecType rs) = return 
     [(P (Vr argv) lab, ptyp) | (lab,ptyp) <- rs,  not (isLinLabel lab)] 
   ---getParam (_,ty) | ty==typeStr = return [] --- in lindef 
   getParam (av,ty) = 
     Bad ("record type expected not" +++ prt ty +++ "for" +++ prt av) 
     --- all lin types are rec types

   replace :: [(Term,Term)] -> Term -> Term
   replace reps trm = case trm of  
     -- this is the important case
     P _ _ -> maybe trm id $ lookup trm reps
     _ -> composSafeOp (replace reps) trm

   occur t trm = case trm of

     -- this is the important case
     P _ _   -> t == trm
     S x y   -> occur t y || occur t x
     App f x -> occur t x || occur t f
     Abs _ f -> occur t f
     R rs    -> any (occur t) (map (snd . snd) rs)
     T _ cs  -> any (occur t) (map snd cs)
     C x y   -> occur t x || occur t y
     Glue x y -> occur t x || occur t y
     ExtR x y -> occur t x || occur t y
     FV ts   -> any (occur t) ts
     V _ ts   -> any (occur t) ts
     Let (_,(_,x)) y -> occur t x || occur t y
     _ -> False


-- here we must be careful not to reduce
--   variants {{s = "Auto" ; g = N} ; {s = "Wagen" ; g = M}}
--   {s  = variants {"Auto" ; "Wagen"} ; g  = variants {N ; M}} ;

recordExpand :: Type -> Term -> Err Term
recordExpand typ trm = case unComputed typ of
  RecType tys -> case trm of
    FV rs -> return $ FV [R [assign lab (P r lab) | (lab,_) <- tys] | r <- rs]
    _ -> return $ R [assign lab (P trm lab) | (lab,_) <- tys]
  _ -> return trm


-- | auxiliaries for compiling the resource

mkLinDefault :: SourceGrammar -> Type -> Err Term
mkLinDefault gr typ = do
  case unComputed typ of
    RecType lts -> mapPairsM mkDefField lts >>= (return . Abs strVar . R . mkAssign)
    _ -> prtBad "linearization type must be a record type, not" typ
 where
   mkDefField typ = case unComputed typ of
     Table p t  -> do
       t' <- mkDefField t
       let T _ cs = mkWildCases t'
       return $ T (TWild p) cs 
     Sort "Str" -> return $ Vr strVar
     QC q p     -> lookupFirstTag gr q p
     RecType r  -> do
       let (ls,ts) = unzip r
       ts' <- mapM mkDefField ts
       return $ R $ [assign l t | (l,t) <- zip ls ts']
     _ | isTypeInts typ -> return $ EInt 0 -- exists in all as first val
     _ -> prtBad "linearization type field cannot be" typ

-- | Form the printname: if given, compute. If not, use the computed
-- lin for functions, cat name for cats (dispatch made in evalCncDef above).
--- We cannot use linearization at this stage, since we do not know the
--- defaults we would need for question marks - and we're not yet in canon.
evalPrintname :: SourceGrammar -> Ident -> MPr -> Perh Term -> Err Term
evalPrintname gr c ppr lin =
  case ppr of
    Yes pr -> comp pr
    _ -> case lin of
      Yes t -> return $ K $ clean $ prt $ oneBranch t ---- stringFromTerm
      _ -> return $ K $ prt c ----
 where
   comp = computeConcrete gr

   oneBranch t = case t of
     Abs _ b   -> oneBranch b
     R   (r:_) -> oneBranch $ snd $ snd r
     T _ (c:_) -> oneBranch $ snd c
     V _ (c:_) -> oneBranch c
     FV  (t:_) -> oneBranch t
     C x y     -> C (oneBranch x) (oneBranch y)
     S x _     -> oneBranch x
     P x _     -> oneBranch x
     Alts (d,_) -> oneBranch d
     _ -> t

  --- very unclean cleaner
   clean s = case s of
     '+':'+':' ':cs -> clean cs
     '"':cs -> clean cs
     c:cs -> c: clean cs
     _ -> s

-}
