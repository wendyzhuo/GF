--# -path=.:../common:../../prelude
--
----1 A Simple German Resource Morphology
----
---- Aarne Ranta & Harald Hammarstr�m 2002 -- 2006
----
---- This resource morphology contains definitions needed in the resource
---- syntax. To build a lexicon, it is better to use $ParadigmsGer$, which
---- gives a higher-level access to this module.
--
resource MorphoGer = ResGer ** open Prelude, (Predef=Predef) in {

  flags optimize=all ;

oper

-- For $StructuralGer$.

  mkPrep : Str -> Case -> Preposition = \s,c -> 
    {s = s ; c = c} ;

  nameNounPhrase : {s : Case => Str} ->  {s : Case => Str ; a : Agr} = \name ->
    name ** {a = agrP3 Sg} ;

  detLikeAdj : Number -> Str -> 
    {s : Gender => Case => Str ; n : Number ; a : Adjf} = \n,dies -> 
      {s = appAdj (regA dies) ! n ; n = n ; a = Weak} ;

-- For $ParadigmsGer$.

  genitS : Str -> Str = \hund -> case hund of {
    _ + ("el" | "en" | "er") => hund + "s" ;
    _ + ("s" | "�" | "sch" | "st" | "x" | "z") => hund + "es" ;
    _ => hund + variants {"s" ; "es"}
    } ;
  pluralN : Str -> Str = \hund -> case hund of {
    _ + ("el" | "en" | "er" | "e") => hund + "n" ;
    _ => hund + "en"
    } ;
  dativE : Str -> Str = \hund -> case hund of {
    _ + ("el" | "en" | "er" | "e") => hund ;
    _ => variants {hund ; hund + "e"}
    } ;


} ;

