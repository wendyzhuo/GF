--# -path=.:../common:../abstract:../../prelude

--1 German Lexical Paradigms
--
-- Aarne Ranta, Harald Hammarstr�m and Bj�rn Bringert2003--2007
--
-- This is an API for the user of the resource grammar 
-- for adding lexical items. It gives functions for forming
-- expressions of open categories: nouns, adjectives, verbs.
-- 
-- Closed categories (determiners, pronouns, conjunctions) are
-- accessed through the resource syntax API, $Structural.gf$. 
--
-- The structure of functions for each word class $C$ is the following:
-- first we give a handful of patterns that aim to cover all
-- cases, from the most regular (with just one argument) to the worst. 
-- The name of this function is $mkC$.
-- 
-- There is also a module [``IrregGer`` ../../german/IrregGer.gf] 
-- which covers irregular verbs.


resource ParadigmsGer = open 
  (Predef=Predef), 
  Prelude, 
  MorphoGer,
  CatGer
  in {

--2 Parameters 

-- To abstract over gender names, we define the following identifiers.

oper
  Gender    : Type ; 

  masculine : Gender ;
  feminine  : Gender ;
  neuter    : Gender ;

-- To abstract over case names, we define the following.

  Case       : Type ; 

  nominative : Case ;
  accusative : Case ;
  dative     : Case ;
  genitive   : Case ;

  anDat_Case : Case ; -- preposition "an" accusative with contraction "am" --%
  inAcc_Case : Case ; -- preposition "in" accusative with contraction "ins" --%
  inDat_Case : Case ; -- preposition "in" dative with contraction "am" --%
  zuDat_Case : Case ; -- preposition "zu" dative with contractions "zum", "zur" --%
  vonDat_Case : Case ;

-- To abstract over number names, we define the following.

  Number    : Type ; 

  singular  : Number ;
  plural    : Number ;


--2 Nouns


mkN : overload {
-- The regular heuristics recognizes some suffixes, from which it
-- guesses the gender and the declension: "e, ung, ion" give the
-- feminine with plural ending "-n, -en", and the rest are masculines
-- with the plural "-e" (without Umlaut).

  mkN : (Stufe : Str) -> N ;  -- die Stufe-Stufen, der Tisch-Tische

-- The 'almost regular' case is much like the information given in an ordinary
-- dictionary. It takes the singular and plural nominative and the
-- gender, and infers the other forms from these.

  mkN : (Bild,Bilder : Str) -> Gender -> N ; -- sg and pl nom, and gender

-- Worst case: give all four singular forms, two plural forms (others + dative),
-- and the gender.

  mkN : (x1,_,_,_,_,x6 : Str) -> Gender -> N ; -- worst case: mann, mann, manne, mannes, m�nner, m�nnern

-- compound nouns

  mkN : Str -> N -> N ;   -- Auto + Fahrer -> Autofahrer

  };


-- Relational nouns need a preposition. The most common is "von" with
-- the dative, and there is a special case for regular nouns.

  mkN2 : overload {
    mkN2 : Str -> N2 ; --%
    mkN2 : N ->   N2 ; -- noun + von
    mkN2 : N -> Prep -> N2 -- noun + other preposition
    } ;   

-- Use the function $mkPrep$ or see the section on prepositions below to  
-- form other prepositions.
-- Some prepositions are moreover constructed in [StructuralGer StructuralGer.html].
--
-- Three-place relational nouns ("die Verbindung von x nach y") need two prepositions.

  mkN3 : N -> Prep -> Prep -> N3 ; -- noun + two prepositions


--3 Proper names and noun phrases
--
-- Proper names, with an "s" genitive and other cases like the
-- nominative, are formed from a string. Final "s" ("Johannes-Johannes") is
-- taken into account.

  mkPN : overload {
    mkPN : Str -> PN ; -- regular name with genitive in "s"

-- If only the genitive differs, two strings are needed.

    mkPN : (nom,gen : Str) -> PN ;  -- name with other genitive

-- In the worst case, all four forms are needed.

    mkPN : (nom,acc,dat,gen : Str) -> PN -- name with all case forms
    } ;



--2 Adjectives

  mkA : overload {

-- The regular adjective formation works for most cases, and includes
-- variations such as "teuer - teurer", "b�se - b�ser".

    mkA : Str -> A ; -- regular adjective, works for most cases

-- Irregular adjectives need three forms - one for each degree.

    mkA : (gut,besser,beste : Str) -> A ; -- irregular comparison

-- Sometimes an extra form is needed for positive forms.

    mkA : (gut,gute,besser,beste : Str) -> A -- irregular positive if ending added

    } ;

-- Invariable adjective are a special case. 

  invarA : Str -> A ;            -- invariable, e.g. prima

-- Two-place adjectives are formed by adding a preposition to an adjective.

  mkA2 : A -> Prep -> A2 ; -- e.g. teilbar + durch

--2 Adverbs

-- Adverbs are formed from strings.

  mkAdv : Str -> Adv ; -- adverbs have just one form anyway


--2 Prepositions

-- A preposition is formed from a string and a case.

  mkPrep : Str -> Case -> Prep ; -- e.g. "durch" + accusative
  
-- Often just a case with the empty string is enough.

  accPrep : Prep ; -- no string, just accusative case
  datPrep : Prep ; -- no string, just dative case
  genPrep : Prep ; -- no string, just genitive case

-- A couple of common prepositions (the first two always with the dative).

  von_Prep : Prep ; -- von + dative
  zu_Prep  : Prep ; -- zu + dative, with contractions zum, zur
  anDat_Prep : Prep ; -- an + dative, with contraction am
  inDat_Prep : Prep ; -- in + dative, with contraction ins
  inAcc_Prep : Prep ; -- in + accusative, with contraction im

--2 Verbs

mkV : overload {

-- Regular verbs ("weak verbs") need just the infinitive form.

  mkV : (f�hren : Str) -> V ; -- regular verb

-- Irregular verbs use Ablaut and, in the worst cases, also Umlaut.

  mkV : (sehen,sieht,sah,s�he,gesehen : Str) -> V ; -- irregular verb theme

-- The worst-case constructor needs six forms:
-- - Infinitive, 
-- - 3p sg pres. indicative, 
-- - 2p sg imperative, 
-- - 1/3p sg imperfect indicative, 
-- - 1/3p sg imperfect subjunctive (because this uncommon form can have umlaut)
-- - the perfect participle 
--
--

  mkV : (geben, gibt, gib, gab, g�be, gegeben : Str) -> V ;  -- worst-case verb

-- To add a movable prefix e.g. "auf(fassen)".

  mkV : Str -> V -> V -- movable prefix, e.g. auf+fassen
};


-- To remove the past participle prefix "ge", e.g. for the verbs
-- prefixed by "be-, ver-".

  no_geV : V -> V ;  -- no participle "ge", e.g. "bedeuten"

-- To add a fixed prefix such as "be-, ver-"; this implies $no_geV$.

  fixprefixV : Str -> V -> V ; -- add prefix such as "be"; implies no_ge

-- To change the auxiliary from "haben" (default) to "sein" and
-- vice-versa.

  seinV  : V -> V ; -- force "sein" as auxiliary
  habenV : V -> V ; -- force "haben" as auxiliary

-- Reflexive verbs can take reflexive pronouns of different cases.

  reflV  : V -> Case -> V ; -- reflexive, with case


--3 Two-place verbs

mkV2 : overload {

-- Two-place regular verbs with direct object (accusative, transitive verbs).

  mkV2 : Str -> V2 ; --%

-- Two-place verbs with direct object.

  mkV2 : V -> V2 ; -- direct object

-- Two-place verbs with a preposition.

  mkV2 : V -> Prep -> V2 ; -- preposition for complement

-- Two-place verbs with object in the given case.

  mkV2 : V -> Case -> V2 ; -- just case for complement
};


--3 Three-place verbs
--
-- Three-place (ditransitive) verbs need two prepositions, of which
-- the first one or both can be absent.

  accdatV3 : V -> V3 ;                  -- geben + acc + dat
  dirV3    : V -> Prep -> V3 ;          -- senden + acc + nach
  mkV3     : V -> Prep -> Prep -> V3 ;  -- sprechen + mit + �ber


--3 Other complement patterns
--
-- Verbs and adjectives can take complements such as sentences,
-- questions, verb phrases, and adjectives.

  mkV0  : V -> V0 ; --%
  mkVS  : V -> VS ;
  mkV2S : V -> Prep -> V2S ;
  mkVV  : V -> VV ;
  mkV2V : V -> Prep -> V2V ;
  mkVA  : V -> VA ;
  mkV2A : V -> Prep -> V2A ;
  mkVQ  : V -> VQ ;
  mkV2Q : V -> Prep -> V2Q ;

  mkAS  : A -> AS ; --%
  mkA2S : A -> Prep -> A2S ; --%
  mkAV  : A -> AV ; --%
  mkA2V : A -> Prep -> A2V ; --%

-- Notice: categories $AS, A2S, AV, A2V$ are just $A$, 
-- and the second argument is given as an adverb. Likewise 
-- $V0$ is just $V$.

  V0 : Type ; --%
  AS, A2S, AV, A2V : Type ; --%


--.
--2 Definitions of paradigms
--
-- The definitions should not bother the user of the API. So they are
-- hidden from the document.



  Gender = MorphoGer.Gender ;
  Case = MorphoGer.PCase ;
  Number = MorphoGer.Number ;
  masculine = Masc ;
  feminine  = Fem ;
  neuter = Neutr ;
  nominative = NPC Nom ;
  accusative = NPC Acc ;
  dative = NPC Dat ;
  genitive = NPC Gen ;
  anDat_Case = NPP CAnDat ;
  inAcc_Case = NPP CInAcc ;
  inDat_Case = NPP CInDat ;
  zuDat_Case = NPP CZuDat ;
  vonDat_Case = NPP CVonDat ;

  singular = Sg ;
  plural = Pl ;

  mk6N a b c d e f g = MorphoGer.mkN a b c d e f g ** {lock_N = <>} ;

  regN : Str -> N = \hund -> case hund of {
    _ + "e" => mk6N hund hund hund hund (hund + "n") (hund + "n") Fem ;
    _ + ("ion" | "ung") => mk6N hund hund hund hund (hund + "en") (hund + "en") Fem ;
    _ + ("er" | "en" | "el") => mk6N hund hund hund (genitS (True | False) hund) hund (pluralN hund) Masc ; 
    _  => mk6N hund hund hund (genitS (True | False) hund) (hund + "e") (pluralN hund) Masc
    } ;

  reg2N : (x1,x2 : Str) -> Gender -> N = \hund,hunde,g -> 
    let hunden = pluralN hunde
    in
    case <hund,hunde,g> of {                                        -- Duden p. 223
      <_,_ + ("e" | "er"), Masc | Neutr> =>                         -- I,IV 
        variants {mk6N hund hund (dativE True  hund) (genitS True  hund) hunde hunden g ;
                  mk6N hund hund (dativE False hund) (genitS False hund) hunde hunden g} ;
      <_ + ("el"|"er"|"en"),_ + ("el"|"er"|"en"), Masc | Neutr> =>  -- II
        mk6N hund hund hund (genitS (True | False) hund) hunde hunden g ;
      <_,_ + "s", Masc | Neutr> =>                                  -- V 
        mk6N hund hund hund (hund + "s") hunde hunde g ;
      <_,_ + "en", Masc> =>                                         -- VI 
        mk6N hund hunde hunde hunde hunde hunde g ;
      <_,_ + ("e" | "er"), Fem> =>                                  -- VII,VIII 
        mk6N hund hund hund hund hunde hunden g ;
      <_,_ + ("n" | "s"), Fem> =>                                   -- IX,X 
        mk6N hund hund hund hund hunde hunde g ;
      _ => {s = (regN hund).s ; g = g ; lock_N = <>}
    } ;
   
  mkN2 = overload {
    mkN2 : Str -> N2 = \s -> vonN2 (regN s) ;
    mkN2 : N ->   N2 = vonN2 ;
    mkN2 : N -> Prep -> N2 = mmkN2
    } ;   


  mmkN2  : N -> Prep -> N2 = \n,p -> n ** {c2 = p ; lock_N2 = <>} ;
  vonN2 : N -> N2 = \n -> n ** {c2 = von_Prep ; lock_N2 = <>} ;

  mkN3 = \n,p,q -> n ** {c2 = p ; c3 = q ; lock_N3 = <>} ;

  mk2PN = \karolus, karoli -> 
    {s = table {Gen => karoli ; _ => karolus} ; lock_PN = <>} ;
  regPN = \horst -> 
    mk2PN horst (ifTok Tok (Predef.dp 1 horst) "s" horst (horst + "s")) ;

  mkPN = overload {
    mkPN : Str -> PN = regPN ;
    mkPN : (nom,gen : Str) -> PN = mk2PN ;
    mkPN : (nom,acc,dat,gen : Str) -> PN = \nom,acc,dat,gen ->
      {s = table {Nom => nom ; Acc => acc ; Dat => dat ; Gen => gen} ; lock_PN = <>} 
    } ;

  mk2PN  : (karolus, karoli : Str) -> PN ; -- karolus, karoli
  regPN : (Johann : Str) -> PN ;  
    -- Johann, Johanns ; Johannes, Johannes


  mk3A : (gut,besser,beste : Str) -> A = \a,b,c ->
    let aa : Str = case a of {
      dunk + "el" => dunk + "l" ;
      te + "uer" => te + "ur" ;
      mud + "e" => mud ;
      _ => a
    } in 
    MorphoGer.mkA a aa b (init c) ** {lock_A = <>} ;
  mk4A : (gut,gute,besser,beste : Str) -> A = \a,aa,b,c ->
    MorphoGer.mkA a aa b (init c) ** {lock_A = <>} ;

  regA : Str -> A = \a -> case a of {
    dunk + "el" => mk3A a (dunk + "ler") (dunk + "leste") ;
    te + "uer" => mk3A a (te + "urer") (te + "ureste") ;
    _ + "e"    => mk3A a (a + "r") (a + "ste") ;
     _ + ("t" | "d" | "s" | "sch" | "z") => mk3A a (a + "er") (a + "este") ;
    _          => mk3A a (a + "er") (a + "ste")
    } ;

  invarA = \s -> {s = \\_,_ => s ; lock_A = <>} ; ---- comparison

  mkA2 = \a,p -> a ** {c2 = p ; lock_A2 = <>} ;

  mkAdv s = {s = s ; lock_Adv = <>} ;

  mkPrep s c = {s = s ; c = c ; isPrep = True ; lock_Prep = <>} ;
  accPrep = {s = [] ; c = accusative ; isPrep = False ; lock_Prep = <>} ;
  datPrep = {s = [] ; c = dative ; isPrep = False ; lock_Prep = <>} ;
  genPrep = {s = [] ; c = genitive ; isPrep = False ; lock_Prep = <>} ;
  --von_Prep = mkPrep "von" dative ;
  von_Prep = mkPrep [] vonDat_Case ;
  zu_Prep = mkPrep [] zuDat_Case ;
  anDat_Prep = mkPrep [] anDat_Case ;
  inDat_Prep = mkPrep [] inDat_Case ; 
  inAcc_Prep = mkPrep [] inAcc_Case ; 


  mk6V geben gibt gib gab gaebe gegeben = 
    let
      geb   = stemVerb geben ;
      gebe  = geb + "e" ;
      gibst = verbST (init gibt) ;
      gebt  = verbT geb ;
      gabst = verbST gab ;
      gaben = pluralN gab ;
      gabt  = verbT gab
    in 
    MorphoGer.mkV 
      geben gebe gibst gibt gebt gib gab gabst gaben gabt gaebe gegeben
      [] VHaben ** {lock_V = <>} ;

  regV fragen = 
    let
      frag    = stemVerb fragen ;
      fragt   = verbT frag ;
      fragte  = fragt + "e" ;
      gefragt : Str = case frag of {
        _ + "ier" => fragt ;
        _ => "ge" + fragt
        } ;
    in
    mk6V fragen fragt (frag + "e") fragte fragte gefragt ;

  irregV singen singt sang saenge gesungen = 
    let
      sing = stemVerb singen ;
    in
    mk6V singen singt sing sang saenge gesungen ;

  prefixV p v = MorphoGer.prefixV p v ** {lock_V = v.lock_V} ;

  habenV v = 
    {s = v.s ; prefix = v.prefix ; lock_V = v.lock_V ; aux = VHaben ; vtype = v.vtype} ;
  seinV v = 
    {s = v.s ; prefix = v.prefix ; lock_V = v.lock_V ; aux = VSein ; vtype = v.vtype} ;
  reflV v c = 
    {s = v.s ; prefix = v.prefix ; lock_V = v.lock_V ; aux = VHaben ; vtype = VRefl (prepC c).c} ;

  no_geV v = let vs = v.s in {
    s = table {
      p@(VPastPart _) => Predef.drop 2 (vs ! p) ;
      p => vs ! p
      } ;
    prefix = v.prefix ; lock_V = v.lock_V ; aux = v.aux ; vtype = v.vtype
    } ;

  fixprefixV s v = let vs = v.s in {
    s = table {
      VInf True => "zu" ++ (s + vs ! VInf False) ;
      p@(VPastPart _) => s + Predef.drop 2 (vs ! p) ;
      p => s + vs ! p
      } ;
    prefix = v.prefix ; lock_V = v.lock_V ; aux = v.aux ; vtype = v.vtype
    } ;

  haben_V = MorphoGer.haben_V ** {lock_V = <>} ;
  sein_V = MorphoGer.sein_V ** {lock_V = <>} ;
  werden_V = MorphoGer.werden_V ** {lock_V = <>} ;

  prepV2 v c   = v ** {c2 = c ; lock_V2 = <>} ;
  dirV2 v = prepV2 v accPrep ;
  datV2 v = prepV2 v datPrep ;

  mkV3 v c d = v ** {c2 = c ; c3 = d ; lock_V3 = <>} ;
  dirV3 v p = mkV3 v (mkPrep [] accusative) p ;
  accdatV3 v = dirV3 v (mkPrep [] dative) ; 

  mkVS v = v ** {lock_VS = <>} ;
  mkVQ v = v ** {lock_VQ = <>} ;
  mkVV v = v ** {isAux = False ; lock_VV = <>} ;

  V0 : Type = V ;
--  V2S, V2V, V2Q : Type = V2 ;
  AS, A2S, AV : Type = A ;
  A2V : Type = A2 ;

  mkV0  v = v ** {lock_V = <>} ;
  mkV2S v p = prepV2 v p ** {lock_V2S = <>} ;
  mkV2V v p = prepV2 v p ** {isAux = False ; lock_V2V = <>} ;
  mkVA  v = v ** {lock_VA = <>} ;
  mkV2A v p = prepV2 v p ** {lock_V2A = <>} ;
  mkV2Q v p = prepV2 v p ** {lock_V2Q = <>} ;

  mkAS  v = v ** {lock_A = <>} ;
  mkA2S v p = mkA2 v p ** {lock_A = <>} ;
  mkAV  v = v ** {lock_A = <>} ;
  mkA2V v p = mkA2 v p ** {lock_A2 = <>} ;

-- pre-overload API and overload definitions

  regN : Str -> N ;
  reg2N : (x1,x2 : Str) -> Gender -> N ;
  mk6N : (x1,_,_,_,_,x6 : Str) -> Gender -> N ; 

  mkN = overload {
    mkN : Str -> N = regN ;
    mkN : (x1,x2 : Str) -> Gender -> N = reg2N ;
    mkN : (x1,_,_,_,_,x6 : Str) -> Gender -> N = mk6N ;
    mkN : Str -> N -> N  -- Auto + Fahrer -> Autofahrer
    = \s,x -> lin N {s = \\n,c => s + Predef.toLower (x.s ! n ! c) ; g = x.g} ;
    };



  regA : Str -> A ;
  mk3A : (gut,besser,beste : Str) -> A ;

  mkA = overload {
    mkA : Str -> A = regA ;
    mkA : (gut,besser,beste : Str) -> A = mk3A ;
    mkA : (gut,gute,besser,beste : Str) -> A = mk4A
    };



  regV : Str -> V ;
  irregV : (x1,_,_,_,x5 : Str) -> V ;
  mk6V : (x1,_,_,_,_,x6 : Str) -> V ;

  prefixV : Str -> V -> V ;

  mkV = overload {
    mkV : Str -> V = regV ;
    mkV : (x1,_,_,_,x5 : Str) -> V = irregV ;
    mkV : (x1,_,_,_,_,x6 : Str) -> V = mk6V ;
    mkV : Str -> V -> V = prefixV
    };


  prepV2  : V -> Prep -> V2 ;

  dirV2 : V -> V2 ;

  datV2 : V -> V2 ;

  mkV2 = overload {
    mkV2 : Str -> V2 = \s -> dirV2 (regV s) ;
    mkV2 : V -> V2 = dirV2 ;
    mkV2 : V -> Prep -> V2 = prepV2;
    mkV2 : V -> Case -> V2 = \v,c -> prepV2 v (lin Prep {s = [] ; c = c ; isPrep = False}) ;
    } ;

}
