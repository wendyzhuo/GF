concrete PhraseLav of Phrase = CatLav ** open Prelude, ResLav in {
  lin
    PhrUtt pconj utt voc = {s = pconj.s ++ utt.s ++ voc.s} ;
    UttS s = s ;

    NoPConj = {s = []} ;
    NoVoc = {s = []} ;
  
{-

    UttQS qs = {s = qs.s ! QDir} ;
    UttImpSg pol imp = {s = pol.s ++ imp.s ! contrNeg True pol.p ! ImpF Sg False} ;
    UttImpPl pol imp = {s = pol.s ++ imp.s ! contrNeg True pol.p ! ImpF Pl False} ;
    UttImpPol pol imp = {s = pol.s ++ imp.s ! contrNeg True pol.p ! ImpF Sg True} ;

    UttIP ip = {s = ip.s ! Nom} ; --- Acc also
    UttIAdv iadv = iadv ;
    UttNP np = {s = np.s ! Nom} ;
    UttVP vp = {s = infVP False vp (agrP3 Sg)} ;
    UttAdv adv = adv ;
    UttCN n = {s = n.s ! Sg ! Nom} ;
    UttCard n = {s = n.s ! Nom} ;
    UttAP ap = {s = ap.s ! agrP3 Sg} ;

    PConjConj conj = {s = conj.s2} ; ---

    VocNP np = {s = "," ++ np.s ! Nom} ;
-}
}
