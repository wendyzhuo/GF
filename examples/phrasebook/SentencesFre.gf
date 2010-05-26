concrete SentencesFre of Sentences = NumeralFre ** SentencesI - [
  QProp,
  IFemale, YouFamFemale, YouPolFemale,
  PYesToNo,
  Superlative
 ] 
  with 
    (Syntax = SyntaxFre), 
    (Symbolic = SymbolicFre), 
    (Lexicon = LexiconFre) ** 
  open SyntaxFre, ExtraFre, Prelude in {

    lincat
      Superlative = {s : Ord ; isPre : Bool} ;
    lin 
      QProp a = 
        lin QS {s = \\_ => (EstcequeS (mkS a)).s} ;
      IFemale = 
        {name = mkNP i8fem_Pron ; isPron = True ; poss = mkQuant i_Pron} ; 
      YouFamFemale = 
        {name = mkNP youSg8fem_Pron ; isPron = True ; poss = mkQuant youSg_Pron} ; 
      YouPolFemale = 
        {name = mkNP youPol8fem_Pron ; isPron = True ; poss = mkQuant youPol_Pron};

      PYesToNo = mkPhrase (lin Utt (ss "si")) ;
}
