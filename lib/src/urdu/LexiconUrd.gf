--# -path=.:prelude

concrete LexiconUrd of Lexicon = CatUrd ** 
--open ResUrd, Prelude in {
  open ParadigmsUrd, Prelude in {

  flags 
    optimize=values ;

  lin
  airplane_N = mkN "jhaz" ;
--  answer_V2S = mkV_3  (mkCmpdVerb (mkN "jwab" ) "dyna" ) (mkCmpdVerb (mkN "jwab") "dlwana") ;
  answer_V2S = mkV2 (mkV  (mkCmpdVerb (mkN "jwab" ) "dyna" )) ;
  apartment_N = mkN "kmrh" ;
  apple_N = mkN "syb" ;
  art_N = mkN "fn" ;
  ask_V2Q = mkV2 (mkV "pwch-na") ;
  baby_N = mkN "bch" ;
  bad_A = mkA "bra" ;
  bank_N = mkN "bank" ;
  beautiful_A = mkA "KwbSwrt" ;
  become_VA = mkV "bnna";
  beer_N = mkN "beer" ;
  beg_V2V =  mkV2V (mkV "mangna") "sE" "kh" False;
  big_A = mkA "bRa" ;
  bike_N = mkN "saycl" feminine ;
  bird_N = mkN "prndh" ;
  black_A =  mkA "kala" ;
--  black_A =  mkA "kala" ;
  blue_A = mkA "nyla" ;
  boat_N = mkN "kXty" ;
  book_N = mkN "ktab" feminine ;
--  boot_N = mkN "boot" ;
--  boss_N = mkN human (mkN "boss") ;
  boy_N = mkN "lRka" ;
  bread_N = mkN "rwty" ;
  break_V2 = mkV2 (mkV "twRna") ;
  broad_A = mkA "kh-la" ;
--  brother_N2 = mkN2 (mkN "bh-ay") (mkPrep "ka")  ; --not correct
  brown_A = mkA "nswary" ;
  butter_N = mkN "mkh-n" ;
  buy_V2 = mkV2 (mkV "Krydna");
  camera_N = mkN "kymrh" ;
  cap_N = mkN "twpy" ;
  car_N = mkN "gaRy" ;
  carpet_N = mkN "tpay^y" ;
  cat_N = mkN "bly" ;
--  ceiling_N = mkN "ceiling" ;
  chair_N = mkN "krsy" ;
  cheese_N = mkN "pnyr" feminine ;
  child_N = mkN "bch"  ;
--  church_N = mkN "church" ;
  city_N = mkN "Xhr" ;
  clean_A = mkA "Saf" ;
  clever_A = mkA "hwXyar" ;
  
--  close_V2 =  mkV2 (mkV  (mkCmpdVerb1 (mkN "bnd" ) (mkV "krna"))); 
  coat_N = mkN "kwT" ;
  cold_A = mkA "Th-nDa" ;
  come_V = mkV "Ana" ;
  computer_N = mkN "kmpywTr" ;
  country_N = mkN "mlk" ;
  cousin_N = mkN (mkCmpdNoun (mkN "cca") (mkN "zad")) ; -- a compund noun made of two nouns
  cow_N = mkN "gaE" feminine ;
  die_V = mkV "mrna" ;
  dirty_A = mkA "gnda" ;
  distance_N3 = mkN3 (mkN "faSlh") (mkPrep "ka" "ky" "kE" "ky" singular) "sE"  ;
  doctor_N = mkN "mealj" ;
  dog_N = mkN "kta" ;
  door_N = mkN "drwzh" ;
  drink_V2 = mkV2 (mkV "pyna");
  easy_A2V = mkA "Asan" "" ;
  eat_V2 = mkV2 (mkV "kh-ana") "kw" ;
--  empty_A = mkA "Kaly" ;
  enemy_N = mkN "dXmn" ;
  factory_N = mkN "karKanh" ;
  father_N2 = mkN2 (mkN "aba") (mkPrep "ka" "ky" "kE" "ky" singular) ;
  fear_VS = mkV "drna";
  find_V2 = mkV2 (mkV "pana") ;
  fish_N = mkN "mch-ly" ;
  floor_N = mkN "frX" ;
  forget_V2 = mkV2 (mkV "bh-wlna")  ;
  fridge_N = mkN "fryg" ;
  friend_N = mkN "dwst" masculine ;
  fruit_N = mkN "ph-l" ;
--  fun_AV = mkAV (regA "fun") ;
  garden_N = mkN "baG" ;
  girl_N = mkN "lRky" ;
  glove_N = mkN "dstanh" ;
  gold_N = mkN "swna" ;
  good_A = mkA "ach-a" ;
  go_V = mkV "jana" ;
  green_A = mkA "sbz" ;
--  harbour_N = mkN "harbour" ;
  hate_V2 = mkV2 (mkV  (mkCmpdVerb (mkN "nfrt" ) "krna" )) ;
  hat_N = mkN "twpy" ;
--  have_V2 = dirV2 (mk5V "have" "has" "had" "had" "having") ;
  hear_V2 = mkV2 (mkV "snna") ;
  hill_N = mkN "phaRy" ;
  hope_VS = mkV  (mkCmpdVerb (mkN "amyd" ) "krna" );
  horse_N = mkN "gh-wRa" ;
  hot_A = mkA "grm" ;
  house_N = mkN "gh-r" ;
  important_A = mkA "ahm" ;
  industry_N = mkN "Snet" feminine ;
--  iron_N = mkN "iron" ;
  king_N = mkN "badXah" ;
  know_V2 = mkV2 (mkV "janna") ;
  lake_N = mkN "jh-yl" feminine ;
--  lamp_N = mkN "lamp" ;
  learn_V2 = mkV2 (mkV "sykh-na") ;
  leather_N = mkN "cmRa" ;
--  leave_V2 = dirV2 (irregV "leave" "left" "left") ;
  like_V2 = mkV2 (mkV  (mkCmpdVerb (mkN "psnd" ) "krna" ));
  listen_V2 = mkV2 (mkV "snna") ;
  live_V = mkV "rhna" ; ---- touch
  long_A = mkA "lmba" ;
  lose_V2 = mkV2 (mkV  (mkCmpdVerb (mkN "kh-w" ) "dyna" )) ;
  love_N = mkN "mHbt" ;
  love_V2 = mkV2 (mkV  (mkCmpdVerb (mkN "pyar" ) "krna" )) ;
  man_N = mkN "Admy" ; -- not correct according to rules should be discussed
  married_A2 = mkA "Xady krna" "sE" ;
  meat_N = mkN "gwXt" ;
  milk_N = mkN "dwdh-" ;
  moon_N = mkN "cand" ;
--  mother_N2 = mkN "maN" feminine ; -- not covered need to be discussed
  mountain_N = mkN "phaRy" ;
  music_N = mkN "mwsyqy" ;
  narrow_A = mkA "baryk" ;
  new_A = mkA "nya" ;
  newspaper_N = mkN "aKbar" ;
  oil_N = mkN "tyl" ;
  old_A = mkA "bwRh-a" ;
  open_V2 = mkV2 (mkV "kh-wlna") ;
  paint_V2A = mkV2 (mkV  (mkCmpdVerb (mkN "rng" ) "krna" )) ;
  paper_N = mkN "kaGz" ;
--  paris_PN = mkPN (mkN nonhuman (mkN "Paris")) ;
  peace_N = mkN "amn" ;
  pen_N = mkN "pnsl" ;
  planet_N = mkN "syarh" ;
--  plastic_N = mkN "plastic" ;
  play_V2 = mkV2 (mkV "kh-ylna") ;
--  policeman_N = mkN masculine (mkN "policeman" "policemen") ;
--  priest_N = mkN human (mkN "priest") ;
--  probable_AS = mkAS (regA "probable") ;
  queen_N = mkN "Xhzady" ;
--  radio_N = mkN "radio" ;
  rain_V0 = mkV  (mkCmpdVerb (mkN "barX" ) "hwna" ) ;
  read_V2 = mkV2 (mkV "pRh-na");
  red_A = mkA "lal" ;
  religion_N = mkN "mzhb" ;
--  restaurant_N = mkN "restaurant" ;
  river_N = mkN "drya" masculine ;
  rock_N = mkN "cTan" ;
  roof_N = mkN "ch-t" masculine ;
--  rubber_N = mkN "rubber" ;
  run_V = mkV "dwRna" ;
  say_VS = mkV "khna" ;
  school_N = mkN "skwl" ;
--  science_N = mkN "science" ;
  sea_N = mkN "smndr" ;
  seek_V2 = mkV2 (mkV  (mkCmpdVerb (mkN "tlaX" ) "krna" )) ;
  see_V2 = mkV2 (mkV "dykh-na") ;
  sell_V3 = mkV3 (mkV "bycna") "kw" "";
  send_V3 = mkV3 (mkV "bh-yjna") "kw" "";
  sheep_N = mkN "bh-yR" feminine ;
  ship_N = mkN "jhaz" ;
  shirt_N = mkN "qmyZ-" feminine;
  shoe_N = mkN "jwta" ;
  shop_N = mkN "dwkan" feminine ;
  short_A = mkA "ch-wTa" ;
  silver_N = mkN "candy" ;
  sister_N = mkN "bhn" feminine ;
  sleep_V = mkV "swna" ;
  small_A = mkA "ch-wTa" ;
  snake_N = mkN "sanp" ;
  sock_N = mkN "jrab" feminine ;
  speak_V2 = mkV2 (mkV "bwlna") ;
  star_N = mkN "stara" ;
--  steel_N = mkN "steel" ;
  stone_N = mkN "pth-r" ;
  stove_N = mkN "cwlha" ;
  student_N = mkN (mkCmpdNoun (mkN "t-alb") (mkN "elm")) ;
  stupid_A = mkA "aHmq" ;
  sun_N = mkN "swrj" ;
--  switch8off_V2 = dirV2 (partV (regV "switch") "off") ;
--  switch8on_V2 = dirV2 (partV (regV "switch") "on") ;
  table_N = mkN "myz" feminine ;
  talk_V3 = mkV3 (mkV "bwlna") "sE" "kE barE meN";
  teacher_N = mkN "istad" ;
  teach_V2 = mkV2 (mkV "pRh-na") ;
  television_N = mkN "telywyzn" ;
  thick_A = mkA "mwTa" ;
  thin_A = mkA "ptla" ;
  train_N = mkN "gaRy" ;
--  travel_V = mkV
  travel_V = mkV  (mkCmpdVerb (mkN "sfr" ) "krna" ) ;
  tree_N = mkN "drKt" masculine ;
-- ---- trousers_N = mkN "trousers" ;
  ugly_A = mkA "bdSwrt" ;
  understand_V2 = mkV2 (mkV "smjh-na") ;
--  university_N = mkN "university" ;
  village_N = mkN "gawN" ;
  wait_V2 = mkV2 (mkV  (mkCmpdVerb (mkN "antz-ar" ) "krna" )) ;
  walk_V = mkV "clna" ;
  warm_A = mkA "grm" ;
  war_N = mkN "jng" ;
--  watch_V2 = dirV2 (regV "watch") ;
--  water_N = mkN "water" ; -- not covered masculine ending with y
  white_A = mkA "sfyd" ;
  window_N = mkN "kh-Rky" ;
  wine_N = mkN "Xrab" feminine ;
  win_V2 = mkV2 (mkV "jytna") ;
  woman_N = mkN "ewrt" feminine ;
--  wonder_VQ = (mkCmpdVerb (mkN "Heran" ) "hwna" ) (mkCmpdVerb (mkN "Heran") "hwna") (mkCmpdVerb (mkN "Heran") "krwana") ;
  wood_N = mkN "lkRy" ;
  write_V2 = mkV2 (mkV "lkh-na") ;
  yellow_A = mkA "pyla" ;
  young_A = mkA "jwan" ;
--
  do_V2 = mkV2 (mkV "krna")  ;
--  now_Adv = mkAdv "now" ;
--  already_Adv = mkAdv "already" ;
  song_N = mkN "gana" ;
--  add_V3 = mkV  (mkCmpdVerb (mkN "aZ-afh" ) "krna" ) ;
  number_N = mkN "hndsh" ;
  put_V2 = mkV2 (mkV "Dalna") ;
  stop_V = mkV "rkna"  ;
  jump_V = mkV "ch-langna" ;
--
--  left_Ord = ss "left" ;
--  right_Ord = ss "right" ;
--  far_Adv = mkA "dwr" ;
  correct_A = mkA "Syh" ;
  dry_A = mkA "KXk" ;
--  dull_A = mkA "nalik" ;
--  full_A = regA "full" ;
  heavy_A = mkA "bh-ary" ;
  near_A = mkA "qryb" ;
--  rotten_A = (regA "rotten") ;
  round_A = mkA "gwl" ;
  sharp_A = mkA "tyz" ;
  smooth_A = mkA "hmwar" ;
  straight_A = mkA "sydh-a" ;
  wet_A = mkA "gyla" ; ----
  wide_A = mkA "kh-la" ;
  animal_N = mkN "janwr" ;
  ashes_N = mkN "rakh-" feminine; -- FIXME: plural only?
  back_N = mkN "qmr" feminine ;
--  bark_N = mkN "bark" ;
  belly_N = mkN "dh-ny" ;
  blood_N = mkN "Kwn" ;
  bone_N = mkN "hDy" ;
  breast_N = mkN "ch-aty" ;
  cloud_N = mkN "badl" ;
  day_N = mkN "dn" ;
  dust_N = mkN "dh-wl" ;
  ear_N = mkN "kan" ;
  earth_N = mkN "zmyn" feminine ;
  egg_N = mkN "anDh" ;
  eye_N = mkN "Ankh-" feminine ;
  fat_N = mkN "mwta" ;
  feather_N = mkN "pr" ;
  fingernail_N = mkN "naKn" ;
  fire_N = mkN "Ag" feminine ;
  flower_N = mkN "ph-wl" ;
  fog_N = mkN "dh-nd" feminine ;
  foot_N = mkN "pawN" ; -- not properly covered need to be discussed
  forest_N = mkN "njgl" ;
  grass_N = mkN "gh-s" feminine ;
--  guts_N = mkN "gut" ; -- FIXME: no singular
  hair_N = mkN "bal" ;
  hand_N = mkN "hath-" ;
  head_N = mkN "sr" ;
  heart_N = mkN "dl" ;
  horn_N = mkN "gh-nty" ;
  husband_N = mkN "Xwhr" ;
  ice_N = mkN "brf" feminine ;
  knee_N = mkN "khny" ;
  leaf_N = mkN "pth" ;
  leg_N = mkN "tang" feminine ;
  liver_N = mkN "jgr" ;
  louse_N = mkN "gh-r" ;
  mouth_N = mkN "mnh" ;
  name_N = mkN "nam" ;
  neck_N = mkN "grdn" feminine ;
  night_N = mkN "rat" feminine ;
  nose_N = mkN "nak" ;
  person_N = mkN "XKS" ;
  rain_N = mkN "barX" feminine ;
  road_N = mkN "sRk" ;
  root_N = mkN "gR" feminine ;
  rope_N = mkN "rsy" ;
  salt_N = mkN "nmk" feminine ;
  sand_N = mkN "ryt" feminine ;
  seed_N = mkN "byj"  ;
  skin_N = mkN "jld" feminine ;
  sky_N = mkN "Asman" ;
  smoke_N = mkN "dh-waN"; -- singular masc nouns ending with aN,wN yet to be implemented
  snow_N = mkN "brf" feminine ;
  stick_N = mkN "ch-Ry" ;
  tail_N = mkN "dm" ;
  tongue_N = mkN "zban" feminine ;
  tooth_N = mkN "dant" masculine;
  wife_N = mkN "bywy" ;
  wind_N = mkN "Andh-y" ;
  wing_N = mkN "pr" ;
  worm_N = mkN "grm" ;
  year_N = mkN "sal" ;
  blow_V = mkV "clna" ;
  breathe_V = mkV  (mkCmpdVerb (mkN "sans" ) "lyna" ) ;
  burn_V = mkV "jlna" ;
  dig_V = mkV "kh-wdna" ;
  fall_V = mkV "grna" ;
  float_V = mkV "tyrna" ;
  flow_V = mkV  "bhna" ;
  fly_V = mkV "aRna" ;
  freeze_V = mkV "jmna";
  give_V3 = mkV3 (mkV "dyna") "kw" "";
  laugh_V = mkV "hnsna" ;
--  lie_N = mkN "jh-wt" masculine ;
--  lie_V = mkV_3 (mkCmpd lie_N "bwlna") (mkCmpd lie_N "bwlwana") ;
--  lie_V = mkV_3 (mkCmpdVerb (mkN "jh-wt" masculine) "bwlna" ) (mkCmpdVerb (mkN "jh-wt" masculine) "bwlwana") ;
  lie_V = mkV (mkCmpdVerb (mkN "jh-wt" masculine) "bwlna" );
  play_V = mkV "kh-ylna" ;
  sew_V = mkV "syna" ;
  sing_V = mkV "gana" ;
  sit_V = mkV "byTh-na" ;
--  smell_V = regV "smell" ;
--  spit_V = IrregUrd.spit_V ;
--  stand_V = IrregUrd.stand_V ;
  swell_V = mkV "swjh-na" ;
  swim_V = mkV "tyrna" ;
  think_V = mkV "swcna" ;
  turn_V = mkV "mRna";
--  vomit_V = regV "vomit" ;
--
  bite_V2 = mkV2 (mkV "katna") ;
  count_V2 = mkV2 (mkV "gnna") ;
  cut_V2 = mkV2 (mkV "katna") ;
  fear_V2 = mkV2 (mkV "Drna") ;
  fight_V2 = mkV2 (mkV "lRna") ;
  hit_V2 = mkV2 (mkV (mkCmpdVerb (mkN "th-wkr" ) "marna" ));
  hold_V2 = mkV2 (mkV "pkRna") ;
  hunt_V2 = mkV2 (mkV  (mkCmpdVerb (mkN "Xkar" ) "krna" ));
  kill_V2 =  mkV2 (mkV (mkCmpdVerb (mkN "mar" ) "Dalna" )) ;
  pull_V2 = mkV2 (mkV "kh-ncna");
--  push_V2 = dirV2 (regV "push") ;
  rub_V2 = mkV2 (mkV "rgRna") ;
--  scratch_V2 = dirV2 (regV "scratch") ;
--  split_V2 = dirV2 split_V ;
--  squeeze_V2 = dirV2 (regV "squeeze") ;
--  stab_V2 = dirV2 (regDuplV "stab") ;
  suck_V2 = mkV2 (mkV "cwsna") ;
  throw_V2 = mkV2 (mkV "ph-ynkna") ;
  tie_V2 = mkV2 (mkV "bandh-na") ;
  wash_V2 = mkV2 (mkV "dh-wna") ;
--  wipe_V2 = dirV2 (regV "wipe") ;
--
----  other_A = regA "other" ;
--
--  grammar_N = mkN "grammar" ;
  language_N = mkN "zban" feminine ;
  rule_N = mkN "aSwl" ;
--
---- added 4/6/2007
    john_PN = mkPN "jon" ;
    question_N = mkN "swal" ;
--    ready_A = regA "ready" ;
    reason_N = mkN "wjh" feminine ;
--    today_Adv = mkAdv "today" ;
--    uncertain_A = regA "uncertain" ;
--
--oper
--  aboutP = mkPrep "about" ;
--  atP = mkPrep "at" ;
--  forP = mkPrep "for" ;
--  fromP = mkPrep "from" ;
--  inP = mkPrep "in" ;
--  onP = mkPrep "on" ;
--  toP = mkPrep "to" ;
--
  
 
}