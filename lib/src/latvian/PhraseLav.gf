--# -path=.:../abstract:../common:../prelude

concrete PhraseLav of Phrase = CatLav ** open
  ResLav,
  VerbLav
  in {

flags
  coding = utf8 ;

lin
  PhrUtt pconj utt voc = { s = pconj.s ++ utt.s ++ voc.s } ;

  UttS s = { s = s.s } ;
  UttQS qs = { s = qs.s } ;
  UttImpSg pol imp = { s = pol.s ++ imp.s ! pol.p ! Sg } ;
  UttImpPl pol imp = { s = pol.s ++ imp.s ! pol.p ! Pl } ;
  UttImpPol pol imp = { s = pol.s ++ "lūdzu" ++ imp.s ! pol.p ! Pl } ;

  UttNP np = { s = np.s ! Nom } ;
  UttCN n = { s = n.s ! Indef ! Sg ! Nom } ;
  UttAP ap = { s = ap.s ! Indef ! Masc ! Sg ! Nom } ;
  UttAdv adv = adv ;

  -- FIXME: neesmu līdz galam drošs vai agreement ir tieši (AgPr Pl)
  UttVP vp = { s = build_VP vp Pos VInf (AgP3 Pl Masc Pos) } ;

  UttIP ip = { s = ip.s ! Nom } ;
  UttIAdv iadv = iadv ;
  UttCard n = { s = n.s ! Masc ! Nom } ;

  NoPConj = { s = [] } ;
  NoVoc = { s = [] } ;

  VocNP np = { s = "," ++ np.s ! ResLav.Voc } ;
  PConjConj conj = { s = conj.s2 } ;

}
