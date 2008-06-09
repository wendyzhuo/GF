--# -path=.:../../prelude

--1 A Simple English Resource Morphology
--
-- Aarne Ranta 2002 -- 2005
--
-- This resource morphology contains definitions needed in the resource
-- syntax. To build a lexicon, it is better to use $ParadigmsEng$, which
-- gives a higher-level access to this module.

resource MorphoBul = ResBul ** open
  Predef,
  Prelude,
  CatBul
  in {

  flags optimize=all ;

oper
--2 Determiners

  mkDeterminerSg : Str -> Str -> Str -> {s : DGender => Role => Str; n : Number; countable : Bool ; spec : Species} = \vseki,vsiaka,vsiako ->
    {s = \\g,_ => table DGender [vseki;vseki;vsiaka;vsiako] ! g; n = Sg; countable = False; spec = Indef} ;
  mkDeterminerPl : Str -> {s : DGender => Role => Str ; n : Number; countable : Bool ; spec : Species} = \vsicki ->
    {s = \\_,_ => vsicki; n = Pl; countable = False; spec = Indef} ;

  mkQuant : Str -> Str -> Str -> Str -> {s : AForm => Str} = \tozi,tazi,towa,tezi -> {
    s = \\aform => case aform of {
                     ASg Masc _    => tozi ;
                     ASgMascDefNom => tozi ;
                     ASg Fem  _    => tazi ;
                     ASg Neut _    => towa ;
                     APl      _    => tezi
                   }
    } ;


--2 Verbs

  mkVerb : (_,_,_,_,_,_,_,_,_:Str) -> VTable = 
    \cheta,chete,chetoh,chetqh,chel,chetql,cheten,chetqst,cheti ->
        table {
          VPres      Sg P1 => cheta;
          VPres      Sg P2 => chete + "�";
          VPres      Sg P3 => chete;
          VPres      Pl P1 => case chete of {
                                _ + ("�"|"�") => chete + "��";
                                _             => chete + "�"
                              };
          VPres      Pl P2 => chete + "��";
          VPres      Pl P3 => case cheta of {
                                vika + "�" => case chete of {
                                                dad + "�" => dad + "��";
                                                vika      => vika + "�"
                                              };
                                _          => cheta + "�"
                              };
          VAorist    Sg P1 => chetoh;
          VAorist    Sg _  => case chetoh of {
                                chet+"��" => chete;
                                zova+ "�" => zova
                              };
          VAorist    Pl P1 => chetoh + "��";
          VAorist    Pl P2 => chetoh + "��";
          VAorist    Pl P3 => chetoh + "�";
          VImperfect Sg P1 => chetqh;
          VImperfect Sg _  => case chete of {
	                        rabot + "�" => rabot + "e��";
	                        _           => chete + "��"
                              };
          VImperfect Pl P1 => chetqh + "��";
          VImperfect Pl P2 => chetqh + "��";
          VImperfect Pl P3 => chetqh + "�";
          VPerfect aform   =>let chel1 : Str =
                                   case chel of {
                                     pas+"��" => pas+"�";
                                     _        => chel
                                   }
                             in (mkAdjective chel
                                             (chel+"��")
                                             (chel+"���")
                                             (chel1+"a")
                                             (chel1+"���")
                                             (chel1+"�")
                                             (chel1+"���")
                                             (ia2e chel1+"�")
                                             (ia2e chel1+"���")).s ! aform ;
          VPluPerfect aform => regAdjective chetql  ! aform ;
          VPassive    aform => regAdjective cheten  ! aform ;
          VPresPart   aform => regAdjective chetqst ! aform ;
          VImperative Sg => cheti;
          VImperative Pl => case cheti of {
	                      chet + "�" => chet + "���";
	                      ela        => ela  + "��"
                            };
          VGerund => case chete of {
                       rabot + "�" => rabot + "����";
                       _           => chete + "���"
                     }
        } ;


--2 Nouns

  mkNoun : Str -> Str -> Str -> Str -> DGender -> N = \sg,pl,count,voc,g -> {
    s = table {
          NF Sg Indef => sg ;
          NF Sg Def   => case sg of {
                           _+"�"=>sg+"��" ;
                           _+"�"=>sg+"��" ;
                           _+"�"=>sg+"��" ;
                           _+"�"=>sg+"��" ;
                           _+"�"=>sg+"��" ;
                           s+"�"=>s +"�"  ;
                           _+("���"|"��"|"��"|"���"
                             |"���"|"����"|"���"
                             |"���"|"����"|"���"
                             |"���"|"�����"|"�����")
                                =>sg +"�" ;
                           _    =>case g of {
                                    DFem => sg+"��" ;
                                    _    => sg+"�"
                                  }
                         } ;
          NF Pl Indef => pl ;
          NF Pl Def   => case pl of {
                           _+"�"=>pl+"��" ;
                           _+"�"=>pl+"��" ;
                           _+"�"=>pl+"��" ;
                           s+"�"=>s +"��" ;
                           s    =>s +"��"
                         } ;
          NFSgDefNom  => case sg of {
                           _+"�"=>sg+"��" ;
                           _+"�"=>sg+"��" ;
                           _+"�"=>sg+"��" ;
                           _+"�"=>sg+"��" ;
                           _+"�"=>sg+"��" ;
                           s+"�"=>s +"��" ;
                           _+("���"|"��"|"��"|"���"
                             |"���"|"����"|"���"
                             |"���"|"����"|"���"
                             |"���"|"�����"|"�����")
                                =>sg+"��" ;
                           _    =>case g of {
                                    DFem => sg+"��" ;
                                    _    => sg+"��"
                                  }
                         } ;
          NFPlCount   => count ;
          NFVocative  => voc
        } ;
    g = g ;
    lock_N = <>
    } ;


--2 Adjectives
    
  mkAdjective : (_,_,_,_,_,_,_,_,_ : Str) -> A = 
          \dobyr,dobria,dobriat,dobra,dobrata,dobro,dobroto,dobri,dobrite -> {
    s = table {
          ASg Masc Indef => dobyr ;
          ASg Masc Def   => dobria ;
          ASgMascDefNom  => dobriat ;
          ASg Fem  Indef => dobra ;
          ASg Fem  Def   => dobrata ;
          ASg Neut Indef => dobro ;
          ASg Neut Def   => dobroto ;
          APl Indef      => dobri ;
          APl Def        => dobrite
        } ;
    adv = dobro ;
    lock_A = <>
    } ;
}