--# -path=.:alltenses:prelude
--# -path=.:./present:c:/gf/lib/src/prelude:c:/gf/lib/src/abstract:c:/gf/lib/src/api:c:/gf/lib/src/urdu:c:/gf/lib/src/common 
resource TryUrd = SyntaxUrd - [mkAdN] , LexiconUrd, ParadigmsUrd - [mkAdv,mkDet,mkIP,mkAdN] ** 
  open (P = ParadigmsUrd) in {

oper

  mkAdv = overload SyntaxUrd {
    mkAdv : Str -> Adv = P.mkAdv ;
  } ;

  mkAdN = overload {
    mkAdN : CAdv -> AdN = SyntaxUrd.mkAdN ;
---   mkAdN : Str -> AdN = P.mkAdN ;
  } ;

--  mkOrd = overload SyntaxUrd {
--    mkOrd : A -> Ord = SyntaxUrd.OrdSuperl ;
--  } ;


}
