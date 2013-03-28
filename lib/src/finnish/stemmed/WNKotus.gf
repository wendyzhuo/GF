--# -path=.:..:../../abstract:../../common:../../english:../kotus

resource WNKotus = open Kotus, MorphoFin, ParadigmsFin, Prelude in {

-- interpretations of paradigms in KOTUS word list, used in DictFin built with the Finnish Wordnet

oper vowelHarmony = vowHarmony ;

oper

-- lexicon constructors

  compoundN : Str -> NForms -> N

  mkWN = overload {
    mkWN : (_ : Str)     -> N = \s -> mkN s ;
    mkWN : (_,_ : Str)   -> N = \s,p -> mkN (s ++ p) ;
    mkWN : (_,_,_ : Str) -> N = \s,p,q -> mkN (s ++ p ++ q) ;
    mkWN : (_,_,_,_ : Str) -> N = \s,p,q,r -> mkN (s ++ p ++ q ++ r) ;
    mkWN : (_,_,_,_,_ : Str) -> N = \s,p,q,r,x -> mkN (s ++ p ++ q ++ r ++ x) ;
    mkWN : (_,_,_,_,_,_ : Str) -> N = \s,p,q,r,x,y -> mkN (s ++ p ++ q ++ r ++ x ++ y) ;
    mkWN : (_,_,_,_,_,_,_ : Str) -> N = \s,p,q,r,x,y,z -> mkN (s ++ p ++ q ++ r ++ x ++ y ++ z) ;
    mkWN : (_,_,_,_,_,_,_,_ : Str) -> N = \s,p,q,r,x,y,z,u -> mkN (s ++ p ++ q ++ r ++ x ++ y ++ z ++ u) ;
    mkWN : (_,_,_,_,_,_,_,_,_ : Str) -> N = \s,p,q,r,x,y,z,u,v -> mkN (s ++ p ++ q ++ r ++ x ++ y ++ z ++ u ++ v) ;
    } ;


  mkWA = overload {
    mkWA : (_ : Str)     -> A = \s -> mkA s ;
    mkWA : (_,_ : Str)   -> A = \s,p -> mkA (s ++ p) ;
    mkWA : (_,_,_ : Str) -> A = \s,p,q -> mkA (s ++ p ++ q) ;
    } ;

  mkWV = overload {
    mkWV : (_ : Str)   -> V   = \s -> mkV s ;
    mkWV : (_,_ : Str) -> V   = \s,p -> partV (mkV s) p ;
    mkWV : (_,_,_ : Str) -> V   = \s,p,q -> partV (mkV s) (p ++ q) ;
    mkWV : (_,_,_,_ : Str) -> V   = \s,p,q,r -> partV (mkV s) (p ++ q ++ r) ;
    } ;

  mkWAdv = overload {
    mkWAdv : (_ : Str)     -> WAdv = \s -> ParadigmsEng.mkAdv s ;
    mkWAdv : (_,_ : Str)   -> WAdv = \s,p -> ParadigmsEng.mkAdv (s ++ p) ;
    mkWAdv : (_,_,_ : Str) -> WAdv = \s,p,q -> ParadigmsEng.mkAdv (s ++ p ++ q) ;
    mkWAdv : (_,_,_,_ : Str) -> WAdv = \s,p,q,r -> ParadigmsEng.mkAdv (s ++ p ++ q ++ r) ;
    mkWAdv : (_,_,_,_,_ : Str) -> WAdv = \s,p,q,r,s -> ParadigmsEng.mkAdv (s ++ p ++ q ++ r ++ s) ;
    } ;


-- kotus paradigms

  k1 : Str -> NForms -- 1780 �ljy
    = \s -> dUkko s (s + "n") ;
  k1A : Str -> NForms -- 166 y�kk�
    = \s -> dUkko s (weakGrade s + "n") ;
  k2 : Str -> NForms -- 1189 ��ntely
    = \s -> dSilakka s (s + "n") (s + "j" + getHarmony (last s)) ;
  k3 : Str -> NForms -- 481 ��nti�
    = \s -> dSilakka s (s + "n") (s + "it" + vowelHarmony s) ;
  k4A : Str -> NForms -- 273 �p�rikk�
    = \s -> let ws = weakGrade s in 
      dSilakka s (ws + "n") (ws + "it" + getHarmony (last s)) ;
  k5 : Str -> NForms -- 3212 �ljymaali
    = \s -> case last s of {
              "i" => dPaatti s (s + "n") ;
              _   => dUnix s
              } ;
  k5A : Str -> NForms -- 1959 �yl�tti
    = \s -> dPaatti s (weakGrade s + "n") ;
  k6 : Str -> NForms -- 1231 �ykk�ri
    = \s -> dTohtori s ;
  k7 : Str -> NForms -- 81 vuoksi
    = \s -> dArpi s (init s + "en") ;
  k7A : Str -> NForms -- 70 v�ki
    = \s -> dArpi s (init (weakGrade s) + "en") ;
  k8 : Str -> NForms -- 99 � la carte
    = \s -> dNukke s (s + "n") ;
  k8A : Str -> NForms -- 5 vinaigrette
    = \s -> dNukke s (weakGrade s + "n") ;
  k9 : Str -> NForms -- 696 ��riraja
    = \s -> let a = last s in dSilakka s         
              (s + "n")
              (init s + case a of {"a" => "o" ; _ => "�"} + "j" + a) ;
  k9A : Str -> NForms -- 1040 ��niraita
    = \s -> let a = last s in dSilakka s         
              (weakGrade s + "n")
              (init s + case a of {"a" => "o" ; _ => "�"} + "j" + a) ;
  k10 : Str -> NForms -- 2119 ��nitt�j�
    = \s -> dSilakka s (s + "n") (init s + "i" + vowelHarmony (last s)) ;
  k10A : Str -> NForms -- 284 �nkk�
    = \s -> dSilakka s (weakGrade s + "n") (init s + "i" + vowelHarmony (last s)) ;
  k11 : Str -> NForms -- 46 �deema
    = \s -> dSilakka s (weakGrade s + "n") (init s + "i" + vowelHarmony (last s)) ;
  k12 : Str -> NForms -- 1125 �rin�
    = \s -> let a = vowelHarmony (last s) in 
      dSilakka s (s + "n") 
        (init s + case a of {"a" => "o" ; _ => "�"} + "it" + a) ;
  k13 : Str -> NForms -- 157 virtaska
    = \s -> let a = vowelHarmony (last s) in 
      dSilakka s (s + "n") 
        (init s + case a of {"a" => "o" ; _ => "�"} + "j" + a) ;
  k14A : Str -> NForms -- 244 �t�kk�
    = \s -> let a = vowelHarmony (last s) ; ws = weakGrade s in 
      dSilakka s (ws + "n") 
        (init ws + case a of {"a" => "o" ; _ => "�"} + "it" + a) ;
  k15 : Str -> NForms -- 170 �re�
    = dKorkea ;
  k16 : Str -> NForms -- 2 kumpikin --?
    = \s -> let kumpi = Predef.take 5 s ; kin = Predef.drop 5 s in 
         \\i => (dSuurempi kumpi ! i + kin) ;
  k16A : Str -> NForms -- 20 ylempi
    = dSuurempi ;
  k17 : Str -> NForms -- 38 virkkuu
    = dPaluu ;
  k18 : Str -> NForms -- voi, tee, s��
    = dPuu ;
  k19 : Str -> NForms -- 6 y�
    = dSuo  ;
  k20 : Str -> NForms -- 46 voodoo
    = dPaluu ;
  k21 : Str -> NForms -- 22 tax-free --? ros�
    = dPuu ;
  k22 : Str -> NForms -- 13 tournedos
    = \s -> nForms10
      s (s + "'n") (s + "'ta") (s + "'na") (s + "'hon")
      (s + "'iden") (s + "'ita") (s + "'ina") (s + "'issa") (s + "'ihin") ;
  k23 : Str -> NForms -- 9 vuohi
    = \s -> dArpi s (init s + "en") ;
  k24 : Str -> NForms -- 20 uni
    = \s -> dArpi s (init s + "en") ;
  k25 : Str -> NForms -- 9 tuomi
    = \s -> dArpi s (init s + "en") ;
  k26 : Str -> NForms -- 113 ��ri
    = \s -> dArpi s (init s + "en") ;
  k27 : Str -> NForms -- 23 vuosi
    = \s -> dArpi s (Predef.tk 2 s + "den") ;
  k28 : Str -> NForms -- 13 virsi
    = \s -> dArpi s (Predef.tk 2 s + "ren") ;
  k28A : Str -> NForms -- 1 j�lsi
    = \s -> dArpi s (Predef.tk 2 s + "len") ;
  k29 : Str -> NForms -- 1 lapsi
    = \s -> let lapsi = dArpi s (init s + "en") in 
       table {2 => Predef.tk 3 s + "ta" ; i => lapsi ! i} ;
  k30 : Str -> NForms -- 2 veitsi
    = \s -> let lapsi = dArpi s (init s + "en") in 
       table {2 => Predef.tk 3 s + "st�" ; i => lapsi ! i} ;
  k31 : Str -> NForms -- 3 yksi
    = \s -> let 
        y = Predef.tk 3 s ;
        a = vowelHarmony y
      in nForms10
        s (y + "hden") (y + "ht" + a) (y + "hten" + a) (y + "hteen")
        (s + "en") (s + a) (s + "n" + a) (s + "ss" + a) (s + "in") ;
  k32 : Str -> NForms -- 20 uumen
    = \s -> dPiennar s (s + "en") ;
  k32A : Str -> NForms -- 54 yst�v�t�r
    = \s -> dPiennar s (strongGrade (init s) + last s + "en") ;
  k33 : Str -> NForms -- 168 v�istin
    = \s -> dLiitin s (init s + "men") ;
  k33A : Str -> NForms -- 181 yllytin
    = \s -> dLiitin s (strongGrade (init s) + "men") ;
  k34 : Str -> NForms -- 1 alaston
    = \s -> let alastom = init s in 
      nForms10
        s (alastom + "an") (s + "ta") (alastom + "ana") (alastom + "aan")
        (alastom + "ien") (alastom + "ia") (alastom + "ina") (alastom + "issa")
        (alastom + "iin") ;
  k34A : Str -> NForms -- 569 ��ret�n
    = dOnneton ;
  k35A : Str -> NForms -- 1 l�mmin
    = \s -> let l�mpim = strongGrade (init s) + "m" in
      nForms10
        s (l�mpim + "�n") (s + "t�") (l�mpim + "�n�") (l�mpim + "��n")
        (l�mpim + "ien") (l�mpim + "i�") (l�mpim + "in�") (l�mpim + "iss�")
        (l�mpim + "iin") ;
  k36 : Str -> NForms -- 11 ylin
    = dSuurin ;
  k37 : Str -> NForms -- 1 vasen
    = \s -> let vasem = init s + "m" in 
      nForms10
        s (vasem + "man") (s + "ta") (vasem + "pana") (vasem + "paan")
        (vasem + "pien") (vasem + "pia") (vasem + "pina") (vasem + "missa")
        (vasem + "piin") ;
  k38 : Str -> NForms -- 4195 �ykk�rim�inen
    = dNainen ;
  k39 : Str -> NForms -- 2730 �r�hdys
    = dJalas ;
  k40 : Str -> NForms -- 2482 �ykk�rim�isyys
    = dLujuus  ;
  k41 : Str -> NForms -- 127 �yr�s
    = \s -> let is = init s in dRae s (is + last is + "n") ;
  k41A : Str -> NForms -- 401 �ljykangas
    = \s -> let is = init s in dRae s (strongGrade is + last is + "n") ;
  k42 : Str -> NForms -- 1 mies
    = \s -> let mieh = init s + "s" in 
      nForms10
        s (mieh + "en") (s + "t�") (mieh + "en�") (mieh + "een")
        (s + "ten") (mieh + "i�") (mieh + "in�") (mieh + "iss�")
        (mieh + "iin") ;
  k43 : Str -> NForms -- 11 tiehyt
    = \s -> dRae s (init s + "en") ;
  k43A : Str -> NForms -- 1 immyt
    = \s -> dRae s (strongGrade (init s) + "en") ;
  k44 : Str -> NForms -- 1 kev�t
    = \s -> let kev� = init s in 
      nForms10
        s (kev� + "�n") (s + "t�") (kev� + "�n�") (kev� + "�seen")
        (s + "iden") (kev� + "it�") (kev� + "in�") (kev� + "iss�")
        (kev� + "isiin") ;
  k45 : Str -> NForms -- 23 yhdes
    = \s -> let yhde = init s ; a = vowelHarmony s in 
      nForms10
        s (yhde + "nnen") (yhde + "tt" + a) (yhde + "nten" + a) (yhde + "nteen")
        (yhde + "nsien") (yhde + "nsi" + a) (yhde + "nsin" + a) (yhde + "nsiss" + a)
        (yhde + "nsiin") ;
  k46 : Str -> NForms -- 1 tuhat
    = \s -> let tuha = init s ; a = vowelHarmony s in 
      nForms10
        s (tuha + "nnen") (tuha + "tt" + a) (tuha + "nten" + a) (tuha + "nteen")
        (tuha + "nsien") (tuha + "nsi" + a) (tuha + "nsin" + a) (tuha + "nsiss" + a)
        (tuha + "nsiin") ;
  k47 : Str -> NForms -- 46 ylirasittunut
    = dOttanut ;
  k48 : Str -> NForms -- 346 �p�re
    = \s -> dRae s (s + last s + "n") ;
  k48A : Str -> NForms -- 481 ��nne
    = \s -> dRae s (strongGrade s + "en") ;
  k49 : Str -> NForms -- 31 vempele
    = \s -> case last s of {
         "e" => dRae s (s + "en") ;
         _ => dPiennar s (s + "en")
        } ;
  k49A : Str -> NForms -- 11 vemmel
    = \s -> dPiennar s (strongGrade (init s) + "len") ;
{-
  k50 : Str -> NForms -- 520 v��r�s��ri
    = \s ->  ;
  k51 : Str -> NForms -- 62 vierasmies
    = \s ->  ;
-}
  k52 : Str -> VForms -- 667 �rjy�
    = \s -> cHukkua s (init s + "n") ;
  k52A : Str -> VForms -- 1568 �ljyynty�
    = \s -> cHukkua s (weakGrade (init s) + "n")  ;
  k53 : Str -> VForms -- 605 ��nest��
    = \s -> let ott = Predef.tk 2 s in 
            cOttaa s (init s + "n") (ott + "in") (ott + "i")  ;
  k53A : Str -> VForms -- 2121 �r�ht��
    = \s -> let ota = weakGrade (init s) in
            cOttaa s (ota + "n") (init ota + "in") (Predef.tk 2 s + "i")  ;
  k54 : Str -> VForms -- 2 pieks��
    = \s -> let ott = Predef.tk 2 s in 
            cOttaa s (init s + "n") (ott + "in") (ott + "i")  ;
  k54A : Str -> VForms -- 316 ��nt��
    = \s -> let ota = weakGrade (init s) ; o = Predef.tk 2 ota in
            cOttaa s (ota + "n") (o + "sin") (o + "si")  ;
  k55A : Str -> VForms -- 7 ylt��
    = c54A  ; --? diff: variation ylti/ylsi
  k56 : Str -> VForms -- 22 valaa
    = \s -> let val = Predef.tk 2 s in 
            cOttaa s (init s + "n") (val + "oin") (val + "oi")  ; -- never �
  k56A : Str -> VForms -- 28 virkkaa
    = \s -> let ota = weakGrade (init s) ; ot = init ota in
            cOttaa s (ota + "n") (ot + "oin") (ot + "oi")  ;
  k57A : Str -> VForms -- 3 saartaa
    = c56A ; --? diff: saartoi/saarsi
  k58 : Str -> VForms -- 13 suitsea
    = \s -> cHukkua s (init s + "n") ;
  k58A : Str -> VForms -- 19 tunkea
    = \s -> cHukkua s (weakGrade (init s) + "n") ;
  k59A : Str -> VForms -- 1 tuntea
    = \s -> let tunte = init s ; tunne = weakGrade tunte ; tuns = Predef.tk 2 tunte + "s" in
      vForms12 s (tunne + "n") (tunte + "e") (tunte + "vat") (tunte + "kaa") (tunne + "taan")
        (tuns + "in") (tuns + "i") (init tunte + "isi") (tunte + "nut") (tunne + "ttu")
        (tunte + "nee") ; -- just one verb
  k60A : Str -> VForms -- 1 l�hte�
    = c58A ; --? diff l�hti/l�ksi, just one verb
  k61 : Str -> VForms -- 249 �yski�
    = \s -> cHukkua s (init s  + "n") ;
  k61A : Str -> VForms -- 153 v��ntelehti�
    = \s -> cHukkua s (weakGrade (init s)  + "n") ;
  k62 : Str -> VForms -- 684 �ykk�r�id�
    = \s -> cJuoda s ;
  k63 : Str -> VForms -- 3 saada
    = c62  ;
  k64 : Str -> VForms -- 8 vied�
    = c62  ;
  k65 : Str -> VForms -- 1 k�yd�
    = \s -> let kay = Predef.tk 2 s ; kavi = init kay + "vi" in
      vForms12 s (kay + "n") kay (kay + "v�t") (kay + "k��") (kay + "d��n")
        (kavi + "n") kavi (kavi + "si") (kay + "nyt") (kay + "tty")
        (kay + "nee") ; -- just one verb
  k66 : Str -> VForms -- 268 �rist�
    = \s -> cKuunnella s (Predef.tk 2 s + "in") ;
  k66A : Str -> VForms -- 3 vavista
    = \s -> cKuunnella s (strongGrade (Predef.tk 3 s) + "sin") ;
  k67 : Str -> VForms -- 704 �llistell�
    = \s -> cKuunnella s (Predef.tk 2 s + "in") ;
  k67A : Str -> VForms -- 634 ��nnell�
    = \s -> cKuunnella s (strongGrade (Predef.tk 3 s) + "lin") ;
  k68 : Str -> VForms -- 49 viheri�id�
    = c62 ; -- diff viheri�in/viheri�itsen
  k69 : Str -> VForms -- 48 villit�
    = \s -> cHarkita s ;
  k70 : Str -> VForms -- 3 sy�st�
    = \s -> cJuosta s (Predef.tk 3 s + "ksen") ;
  k71 : Str -> VForms -- 2 tehd�
    = \s -> let te = Predef.tk 3 s in
      vForms12 s (te + "en") (te + "kee") (te + "kev�t") (te + "hk��") (te + "hd��n")
        (te + "en") (te + "ki") (te + "kisi") (te + "hnyt") (te + "hty")
        (te + "hnee") ; -- just two verbs: n�hd�, tehd�
  k72 : Str -> VForms -- 93 ylet�
    = \s -> cValjeta s (Predef.tk 2 s + "ni") ;
  k72A : Str -> VForms -- 52 yhdet�
    = \s -> cValjeta s (strongGrade (Predef.tk 2 s) + "ni") ;
  k73 : Str -> VForms -- 600 �kseerata
    = \s -> cPudota s (Predef.tk 2 s + "si") ;
  k73A : Str -> VForms -- 313 �nk�t�
    = \s -> cPudota s (strongGrade (Predef.tk 2 s) + "si") ;
  k74 : Str -> VForms -- 99 �ljyt�
    = \s -> cPudota s (Predef.tk 2 s + "si") ;
  k74A : Str -> VForms -- 72 �nget�
    = \s -> cPudota s (strongGrade (Predef.tk 2 s) + "si") ;
  k75 : Str -> VForms -- 39 virit�
    = \s -> cPudota s (Predef.tk 2 s + "si") ;
  k75A : Str -> VForms -- 9 siit�
    = \s -> cPudota s (strongGrade (Predef.tk 2 s) + "si") ;
  k76A : Str -> VForms -- 2 tiet��
    = \s -> let tieta = init s ; tieda = weakGrade tieta ; ties = Predef.tk 2 tieta + "s" in 
      cOttaa s (tieda + "n") (ties + "in") (ties + "i") ; -- only tietaa, taitaa
-- defective verbs
  k77 : Str -> VForms -- 3 vipajaa
    = c56A ; ----
  k78 : Str -> VForms -- 31 �hk��
    = c56A ; ----
  k78A : Str -> VForms -- 1 tuikkaa
    = c56A ; ----
  k99 : Str -> Str -- 5453 �ykk�rim�isesti
    = \s -> s ;

  k101 : Str -> Str -- pronouns etc
    = c99 ; -- dummy

-- compound nouns, latter part inflected
  kcompoundNK : Str -> NForms -> NForms = \x,y -> 
    \\v => x + y ! v ;

--- this is a lot slower
  kccompoundNK : (Str -> NForms) -> Str -> Str -> NForms = \d,x,y -> 
    let ys = d y in \\v => x + ys ! v ;

}

