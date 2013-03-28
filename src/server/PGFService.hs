module PGFService(cgiMain,cgiMain',getPath,
                  logFile,stderrToFile,
                  newPGFCache) where

import PGF (PGF)
import qualified PGF
import Cache
import FastCGIUtils
import URLEncoding

import Network.CGI
import Text.JSON
import Text.PrettyPrint as PP(render, text, (<+>))
import qualified Codec.Binary.UTF8.String as UTF8 (decodeString)
import qualified Data.ByteString.Lazy as BS

import Control.Concurrent
import qualified Control.Exception as E
import Control.Monad
import Control.Monad.State(State,evalState,get,put)
import Data.Char
import Data.Function (on)
import Data.List (sortBy,intersperse,mapAccumL,nub,isSuffixOf)
import qualified Data.Map as Map
import Data.Maybe
import System.Random
import System.Process
import System.Exit
import System.IO
import System.Directory(removeFile)
import Fold(fold) -- transfer function for OpenMath LaTeX

catchIOE :: IO a -> (E.IOException -> IO a) -> IO a
catchIOE = E.catch

logFile :: FilePath
logFile = "pgf-error.log"

newPGFCache = newCache PGF.readPGF

getPath =
    do path <- getVarWithDefault "PATH_TRANSLATED" "" -- apache mod_fastcgi
       if null path
          then getVarWithDefault "SCRIPT_FILENAME" "" -- lighttpd
          else return path

cgiMain :: Cache PGF -> CGI CGIResult
cgiMain cache = handleErrors . handleCGIErrors $
                  cgiMain' cache =<< getPath

cgiMain' :: Cache PGF -> FilePath -> CGI CGIResult
cgiMain' cache path =
    do command <- liftM (maybe "grammar" (urlDecodeUnicode . UTF8.decodeString))
                        (getInput "command")
       case command of
         "download" -> outputBinary    =<< liftIO (BS.readFile path)
         _          -> pgfMain command =<< liftIO (readCache cache path)

pgfMain :: String -> PGF -> CGI CGIResult
pgfMain command pgf =
    case command of
      "parse"          -> out =<< doParse pgf # text % cat % from % limit
      "complete"       -> out =<< doComplete pgf # text % cat % from % limit
      "linearize"      -> out =<< doLinearize pgf # tree % to
      "linearizeAll"   -> out =<< doLinearizes pgf # tree % to
      "linearizeTable" -> out =<< doLinearizeTabular pgf # tree % to
      "random"         -> cat >>= \c -> depth >>= \dp -> limit >>= \l -> to >>= \to -> liftIO (doRandom pgf c dp l to) >>= out
      "generate"       -> out =<< doGenerate pgf # cat % depth % limit % to
      "translate"      -> out =<< doTranslate pgf # text % cat % from % to % limit
      "translategroup" -> out =<< doTranslateGroup pgf # text % cat % from % to % limit
      "grammar"        -> out =<< doGrammar pgf # requestAcceptLanguage
      "abstrtree"      -> outputGraphviz =<< abstrTree pgf # graphvizOptions % tree
      "alignment"      -> outputGraphviz =<< alignment pgf # tree % to
      "parsetree"      -> do t <- tree
                             Just l <- from
                             opts <- graphvizOptions
                             outputGraphviz (parseTree pgf l opts t)
      "abstrjson"      -> out . jsonExpr =<< tree
      "browse"         -> join $ doBrowse pgf # optId % cssClass % href % format "html" % getIncludePrintNames
      "external"       -> do cmd <- getInput "external"
                             input <- text
                             doExternal cmd input
      _                -> throwCGIError 400 "Unknown command" ["Unknown command: " ++ show command]
  where
    out = outputJSONP

    text :: CGI String
    text = liftM (maybe "" (urlDecodeUnicode . UTF8.decodeString)) $ getInput "input"

    tree :: CGI PGF.Tree
    tree = do ms <- getInput "tree"
              s <- maybe (throwCGIError 400 "No tree given" ["No tree given"]) return ms
              t <- maybe (throwCGIError 400 "Bad tree" ["tree: " ++ s]) return (PGF.readExpr s)
              t <- either (\err -> throwCGIError 400 "Type incorrect tree"
                                                     ["tree: " ++ PGF.showExpr [] t
                                                     ,render (PP.text "error:" <+> PGF.ppTcError err)
                                                     ])
                          (return . fst)
                          (PGF.inferExpr pgf t)
              return t

    cat :: CGI (Maybe PGF.Type)
    cat =
       do mcat  <- getInput "cat"
          case mcat of
            Nothing -> return Nothing
            Just "" -> return Nothing
            Just cat -> case PGF.readType cat of
                          Nothing  -> throwCGIError 400 "Bad category" ["Bad category: " ++ cat]
                          Just typ -> return $ Just typ  -- typecheck the category

    optId :: CGI (Maybe PGF.CId)
    optId = maybe (return Nothing) rd =<< getInput "id"
      where
        rd = maybe err (return . Just) . PGF.readCId
        err = throwCGIError 400 "Bad identifier" []

    cssClass, href :: CGI (Maybe String)
    cssClass = getInput "css-class"
    href = getInput "href"

    limit, depth :: CGI (Maybe Int)
    limit = readInput "limit"
    depth = readInput "depth"

    from :: CGI (Maybe PGF.Language)
    from = getLang "from"

    to :: CGI [PGF.Language]
    to = getLangs "to"

    getLangs :: String -> CGI [PGF.Language]
    getLangs i = mapM readLang . maybe [] words =<< getInput i

    getLang :: String -> CGI (Maybe PGF.Language)
    getLang i =
       do mlang <- getInput i
          case mlang of
            Just l@(_:_) -> Just # readLang l
            _            -> return Nothing

    readLang :: String -> CGI PGF.Language
    readLang l =
      case PGF.readLanguage l of
        Nothing -> throwCGIError 400 "Bad language" ["Bad language: " ++ l]
        Just lang | lang `elem` PGF.languages pgf -> return lang
                  | otherwise -> throwCGIError 400 "Unknown language" ["Unknown language: " ++ l]
    
    getIncludePrintNames :: CGI Bool
    getIncludePrintNames = maybe False (const True) # getInput "printnames"

    graphvizOptions =
        PGF.GraphvizOptions # bool "noleaves"
                            % bool "nofun"
                            % bool "nocat"
                            % string "nodefont"
                            % string "leaffont"
                            % string "nodecolor"
                            % string "leafcolor"
                            % string "nodeedgestyle"
                            % string "leafedgestyle"
      where
        string name = maybe "" id # getInput name
        bool name = maybe False toBool # getInput name
        toBool s = s `elem` ["","yes","true","True"]

errorMissingId = throwCGIError 400 "Missing identifier" []

format def = maybe def id # getInput "format"

-- Hook for simple extensions of the PGF service
doExternal Nothing input = throwCGIError 400 "Unknown external command" ["Unknown external command"]
doExternal (Just cmd) input =
  do liftIO $ logError ("External command: "++cmd)
     cmds <- liftIO $ (fmap lines $ readFile "external_services")
                        `catchIOE` const (return [])
     liftIO $ logError ("External services: "++show cmds)
     if cmd `elem` cmds then ok else err
  where
    err = throwCGIError 400 "Unknown external command" ["Unknown external command: "++cmd]
    ok =
      do let tmpfile1 = "external_input.txt"
             tmpfile2 = "external_output.txt"
         liftIO $ writeFile "external_input.txt" input
         liftIO $ system $ cmd ++ " " ++ tmpfile1 ++ " > " ++ tmpfile2
         liftIO $ removeFile tmpfile1
         r <- outputJSONP =<< liftIO (readFile tmpfile2)
         liftIO $ removeFile tmpfile2
         return r

doTranslate :: PGF -> String -> Maybe PGF.Type -> Maybe PGF.Language -> [PGF.Language] -> Maybe Int -> JSValue
doTranslate pgf input mcat mfrom tos mlimit =
  showJSON
     [makeObj ("from".=from : "brackets".=bs : jsonTranslateOutput po)
          | (from,po,bs) <- parse' pgf input mcat mfrom]
  where
    jsonTranslateOutput output =
      case output of
        PGF.ParseOk trees ->
            ["translations".=
              [makeObj ["tree".=tree,
                        "linearizations".=
                            [makeObj ["to".=to, "text".=text, "brackets".=bs]
                               | (to,text,bs)<- linearizeAndBind pgf tos tree]]
                | tree <- maybe id take mlimit trees]]
        PGF.ParseIncomplete -> ["incomplete".=True]
        PGF.ParseFailed n   -> ["parseFailed".=n]
        PGF.TypeError errs -> jsonTypeErrors errs

jsonTypeErrors errs = 
    ["typeErrors".= [makeObj ["fid".=fid, "msg".=show (PGF.ppTcError err)]
                       | (fid,err) <- errs]]

-- used in phrasebook
doTranslateGroup :: PGF -> String -> Maybe PGF.Type -> Maybe PGF.Language -> [PGF.Language] -> Maybe Int -> JSValue
doTranslateGroup pgf input mcat mfrom tos mlimit =
  showJSON
    [makeObj ["from".=langOnly (PGF.showLanguage from),
              "to".=langOnly (PGF.showLanguage to),
              "linearizations".=
                 [toJSObject (("text", doText (doBind alt)) : disamb lg from ts)
                    | (ts,alt) <- output, let lg = length output]
              ]
       | 
         (from,po,bs) <- parse' pgf input mcat mfrom,
         (to,output)  <- groupResults [(t, linearize' pgf tos t) | t <- case po of {PGF.ParseOk ts -> maybe id take mlimit ts; _ -> []}]
          ]
  where
   groupResults = Map.toList . foldr more Map.empty . start . collect
     where
       collect tls = [(t,(l,s)) | (t,ls) <- tls, (l,s,_) <- ls, notDisamb l]
       start ls = [(l,[([t],s)]) | (t,(l,s)) <- ls]
       more (l,s) = Map.insertWith (\ [([t],x)] xs -> insertAlt t x xs) l s

   insertAlt t x xs = case xs of
     (ts,y):xs2 -> if x==y then (t:ts,y):xs2 -- if string is there add only tree
                   else (ts,y) : insertAlt t x xs2
     _ -> [([t],x)]

   doBind = unwords . bind . words
   doText s = case s of
     c:cs | elem (last s) ".?!" -> toUpper c : init (init cs) ++ [last s]
     _ -> s
   bind ws = case ws of
         w : "&+" : u : ws2 -> bind ((w ++ u) : ws2)
         "&+":ws2           -> bind ws2
         w : ws2            -> w : bind ws2
         _ -> ws
   langOnly = reverse . take 3 . reverse

   disamb lg from ts = 
     if lg < 2 
       then [] 
       else [("tree", "-- " ++ groupDisambs [doText (doBind (disambLang from t)) | t <- ts])]

   groupDisambs = unwords . intersperse "/"

   disambLang f t = 
     let 
       disfl lang = PGF.mkCId ("Disamb" ++ lang) 
       disf       = disfl (PGF.showLanguage f) 
       disfEng    = disfl (reverse (drop 3 (reverse (PGF.showLanguage f))) ++ "Eng") 
     in
       if elem disf (PGF.languages pgf)         -- if Disamb f exists use it
         then PGF.linearize pgf disf t          
       else if elem disfEng (PGF.languages pgf) -- else try DisambEng
         then PGF.linearize pgf disfEng t 
       else "AST " ++ PGF.showExpr [] t                   -- else show abstract tree

   notDisamb = (/="Disamb") . take 6 . PGF.showLanguage

doParse :: PGF -> String -> Maybe PGF.Type -> Maybe PGF.Language -> Maybe Int -> JSValue
doParse pgf input mcat mfrom mlimit = showJSON $ map makeObj
     ["from".=from : "brackets".=bs : jsonParseOutput po
        | (from,po,bs) <- parse' pgf input mcat mfrom]
  where
    jsonParseOutput output =
      case output of
        PGF.ParseOk trees   -> ["trees".=maybe id take mlimit trees]
        PGF.TypeError errs  -> jsonTypeErrors errs
        PGF.ParseIncomplete -> ["incomlete".=True]
        PGF.ParseFailed n   -> ["parseFailed".=n]

doComplete :: PGF -> String -> Maybe PGF.Type -> Maybe PGF.Language -> Maybe Int -> JSValue
doComplete pgf input mcat mfrom mlimit = showJSON
    [makeObj ["from".=from, "brackets".=bs, "completions".=cs, "text".=s]
       | from <- froms, let (bs,s,cs) = complete' pgf from cat mlimit input]
  where
    froms = maybe (PGF.languages pgf) (:[]) mfrom
    cat = fromMaybe (PGF.startCat pgf) mcat

doLinearize :: PGF -> PGF.Tree -> [PGF.Language] -> JSValue
doLinearize pgf tree tos = showJSON
    [makeObj ["to".=to, "text".=text,"brackets".=bs]
      | (to,text,bs) <- linearize' pgf tos tree]

doLinearizes :: PGF -> PGF.Tree -> [PGF.Language] -> JSValue
doLinearizes pgf tree tos = showJSON
    [makeObj ["to".=to, "texts".=texts]
       | (to,texts) <- linearizes' pgf tos tree]

doLinearizeTabular :: PGF -> PGF.Tree -> [PGF.Language] -> JSValue
doLinearizeTabular pgf tree tos = showJSON
    [makeObj ["to".=to,
              "table".=[makeObj ["params".=ps,"texts".=ts] | (ps,ts)<-texts]]
       | (to,texts) <- linearizeTabular pgf tos tree]

doRandom :: PGF -> Maybe PGF.Type -> Maybe Int -> Maybe Int -> [PGF.Language] -> IO JSValue
doRandom pgf mcat mdepth mlimit tos =
  do g <- newStdGen
     let trees = PGF.generateRandomDepth g pgf cat (Just depth)
     return $ showJSON
          [makeObj ["tree".=PGF.showExpr [] tree,
                    "linearizations".= doLinearizes pgf tree tos]
             | tree <- limit trees]
  where cat = fromMaybe (PGF.startCat pgf) mcat
        limit = take (fromMaybe 1 mlimit)
        depth = fromMaybe 4 mdepth

doGenerate :: PGF -> Maybe PGF.Type -> Maybe Int -> Maybe Int -> [PGF.Language] -> JSValue
doGenerate pgf mcat mdepth mlimit tos =
    showJSON [makeObj ["tree".=PGF.showExpr [] tree,
                       "linearizations".=
                          [makeObj ["to".=to, "text".=text]
                             | (to,text,bs) <- linearize' pgf tos tree]]
                | tree <- limit trees]
  where
    trees = PGF.generateAllDepth pgf cat (Just depth)
    cat = fromMaybe (PGF.startCat pgf) mcat
    limit = take (fromMaybe 1 mlimit)
    depth = fromMaybe 4 mdepth

doGrammar :: PGF -> Maybe (Accept Language) -> JSValue
doGrammar pgf macc = showJSON $ makeObj
             ["name".=PGF.abstractName pgf,
              "userLanguage".=selectLanguage pgf macc,
              "startcat".=PGF.showType [] (PGF.startCat pgf),
              "categories".=categories,
              "functions".=functions,
              "languages".=languages]
  where
    languages =
       [makeObj ["name".= l, 
                  "languageCode".= fromMaybe "" (PGF.languageCode pgf l)]
          | l <- PGF.languages pgf]
    categories = [PGF.showCId cat | cat <- PGF.categories pgf]
    functions  = [PGF.showCId fun | fun <- PGF.functions pgf]

outputGraphviz code =
  do fmt <- format "png"
     case fmt of
       "gv" -> outputPlain code
       _ -> outputFPS' fmt =<< liftIO (pipeIt2graphviz fmt code)
  where
    outputFPS' fmt bs =
      do setHeader "Content-Type" (mimeType fmt)
         outputFPS bs

    mimeType fmt =
      case fmt of
        "png" -> "image/png"
        "gif" -> "image/gif"
        "svg" -> "image/svg+xml"
    -- ...
        _     -> "application/binary"

abstrTree pgf      opts tree = PGF.graphvizAbstractTree pgf opts' tree
  where opts' = (not (PGF.noFun opts),not (PGF.noCat opts))

parseTree pgf lang opts tree = PGF.graphvizParseTree pgf lang opts tree

alignment pgf tree tos       = PGF.graphvizAlignment pgf tos' tree
  where tos' = if null tos then PGF.languages pgf else tos

pipeIt2graphviz :: String -> String -> IO BS.ByteString
pipeIt2graphviz fmt code = do
    (Just inh, Just outh, _, pid) <-
        createProcess (proc "dot" ["-T",fmt])
                      { std_in  = CreatePipe,
                        std_out = CreatePipe,
                        std_err = Inherit }

    hSetBinaryMode outh True
    hSetEncoding inh  utf8

    -- fork off a thread to start consuming the output
    output  <- BS.hGetContents outh
    outMVar <- newEmptyMVar
    _ <- forkIO $ E.evaluate (BS.length output) >> putMVar outMVar ()

    -- now write and flush any input
    hPutStr inh code
    hFlush inh
    hClose inh -- done with stdin

    -- wait on the output
    takeMVar outMVar
    hClose outh

    -- wait on the process
    ex <- waitForProcess pid

    case ex of
     ExitSuccess   -> return output
     ExitFailure r -> fail ("pipeIt2graphviz: (exit " ++ show r ++ ")")

browse1json pgf id pn = makeObj . maybe [] obj $ PGF.browse pgf id
  where
    obj (def,ps,cs) = if pn then (baseobj ++ pnames) else baseobj
      where
        baseobj = ["def".=def, "producers".=ps, "consumers".=cs]
        pnames = ["printnames".=makeObj [(show lang).=PGF.showPrintName pgf lang id | lang <- PGF.languages pgf]]


doBrowse pgf (Just id) _ _ "json" pn = outputJSONP $ browse1json pgf id pn
doBrowse pgf Nothing   _ _ "json" pn =
    outputJSONP $ makeObj ["cats".=all (PGF.categories pgf),
                           "funs".=all (PGF.functions pgf)]
  where
    all = makeObj . map one
    one id = PGF.showCId id.=browse1json pgf id pn

doBrowse pgf Nothing cssClass href _ pn = errorMissingId
doBrowse pgf (Just id) cssClass href _ pn = -- default to "html" format
  outputHTML $
  case PGF.browse pgf id of
    Just (def,ps,cs) -> "<PRE>"++annotate def++"</PRE>\n"++
                        syntax++
                        (if not (null ps)
                           then "<BR/>"++
                                "<H3>Producers</H3>"++
                                "<P>"++annotateCIds ps++"</P>\n"
                           else "")++
                        (if not (null cs)
                           then "<BR/>"++
                                "<H3>Consumers</H3>"++
                                "<P>"++annotateCIds cs++"</P>\n"
                           else "")++
                        (if pn
                           then "<BR/>"++
                                "<H3>Print Names</H3>"++
                                "<P>"++annotatePrintNames++"</P>\n"
                           else "")
    Nothing          -> ""
  where
    syntax = 
      case PGF.functionType pgf id of
        Just ty -> let (hypos,_,_) = PGF.unType ty
                       e          = PGF.mkApp id (snd $ mapAccumL mkArg (1,1) hypos)
                       rows = ["<TR class=\"my-SyntaxRow\">"++
                               "<TD class=\"my-SyntaxLang\">"++PGF.showCId lang++"</TD>"++
                               "<TD class=\"my-SyntaxLin\">"++PGF.linearize pgf lang e++"</TD>"++
                               "</TR>"
                                            | lang <- PGF.languages pgf]
                   in "<BR/>"++
                      "<H3>Syntax</H3>"++
                      "<TABLE class=\"my-SyntaxTable\">\n"++
                      "<TR class=\"my-SyntaxRow\">"++
                      "<TD class=\"my-SyntaxLang\">"++PGF.showCId (PGF.abstractName pgf)++"</TD>"++
                      "<TD class=\"my-SyntaxLin\">"++PGF.showExpr [] e++"</TD>"++
                      "</TR>\n"++
                      unlines rows++"\n</TABLE>"
        Nothing -> ""

    mkArg (i,j) (_,_,ty) = ((i+1,j+length hypos),e)
      where
        e = foldr (\(j,(bt,_,_)) -> PGF.mkAbs bt (PGF.mkCId ('X':show j))) (PGF.mkMeta i) (zip [j..] hypos)
        (hypos,_,_) = PGF.unType ty

    identifiers = PGF.functions pgf ++ PGF.categories pgf

    annotate []          = []
    annotate (c:cs)
      | isIdentInitial c = let (id,cs') = break (not . isIdentChar) (c:cs)
                           in (if PGF.mkCId id `elem` identifiers
                                 then mkLink id
                                 else if id == "fun" || id == "data" || id == "cat" || id == "def"
                                        then "<B>"++id++"</B>"
                                        else id) ++
                              annotate cs'
      | otherwise        = c : annotate cs

    annotateCIds ids = unwords (map (mkLink . PGF.showCId) ids)
    
    isIdentInitial c = isAlpha c || c == '_'
    isIdentChar    c = isAlphaNum c || c == '_' || c == '\''

    hrefAttr id =
      case href of
        Nothing -> ""
        Just s  -> "href=\""++substId id s++"\""

    substId id [] = []
    substId id ('$':'I':'D':cs) = id ++ cs
    substId id (c:cs) = c : substId id cs

    classAttr =
      case cssClass of
        Nothing -> ""
        Just s  -> "class=\""++s++"\""

    mkLink s = "<A "++hrefAttr s++" "++classAttr++">"++s++"</A>"
    
    annotatePrintNames = "<DL>"++(unwords pns)++"</DL>"
      where pns = ["<DT>"++(show lang)++"</DT><DD>"++(PGF.showPrintName pgf lang id)++"</DD>" | lang <- PGF.languages pgf ]

instance JSON PGF.CId where
    readJSON x = readJSON x >>= maybe (fail "Bad language.") return . PGF.readLanguage
    showJSON = showJSON . PGF.showLanguage

jsonExpr e = evalState (expr e) 0
  where
    expr e = maybe other app (PGF.unApp e)
      where
        other = return (makeObj ["other".=e])

    app (f,es) = do js <- mapM expr es
                    let children=["children".=js | not (null js)]
                    i<-inc
                    return $ makeObj (["fun".=f,"fid".=i]++children)

    inc :: State Int Int
    inc = do i <- get; put (i+1); return i

instance JSON PGF.Expr where
    readJSON x = readJSON x >>= maybe (fail "Bad expression.") return . PGF.readExpr
    showJSON = showJSON . PGF.showExpr []

instance JSON PGF.BracketedString where
    readJSON x = return (PGF.Leaf "")
    showJSON (PGF.Bracket cat fid index fun _ bs) =
        makeObj ["cat".=cat, "fid".=fid, "index".=index, "fun".=fun, "children".=bs]
    showJSON (PGF.Leaf s) = makeObj ["token".=s]

-- * PGF utilities

cat :: PGF -> Maybe PGF.Type -> PGF.Type
cat pgf mcat = fromMaybe (PGF.startCat pgf) mcat

parse' :: PGF -> String -> Maybe PGF.Type -> Maybe PGF.Language -> [(PGF.Language,PGF.ParseOutput,PGF.BracketedString)]
parse' pgf input mcat mfrom = 
   [(from,po,bs) | from <- froms, (po,bs) <- [PGF.parse_ pgf from cat Nothing input]]
  where froms = maybe (PGF.languages pgf) (:[]) mfrom
        cat = fromMaybe (PGF.startCat pgf) mcat

complete' :: PGF -> PGF.Language -> PGF.Type -> Maybe Int -> String
         -> (PGF.BracketedString, String, [String])
complete' pgf from typ mlimit input =
  let (ws,prefix) = tokensAndPrefix input
      ps0 = PGF.initState pgf from typ
      (ps,ws') = loop ps0 ws
      bs       = snd (PGF.getParseOutput ps typ Nothing)
  in if not (null ws')
       then (bs, unwords (if null prefix then ws' else ws'++[prefix]), [])
       else (bs, prefix, maybe id take mlimit $ order $ Map.keys (PGF.getCompletions ps prefix))
  where
    order = sortBy (compare `on` map toLower)

    tokensAndPrefix :: String -> ([String],String)
    tokensAndPrefix s | not (null s) && isSpace (last s) = (ws, "")
                      | null ws = ([],"")
                      | otherwise = (init ws, last ws)
        where ws = words s

    loop ps []     = (ps,[])
    loop ps (w:ws) = case PGF.nextState ps (PGF.simpleParseInput w) of
                       Left  es -> (ps,w:ws)
                       Right ps -> loop ps ws

linearize' :: PGF -> [PGF.Language] -> PGF.Tree -> [(PGF.Language,String,PGF.BracketedString)]
linearize' pgf to tree =
    [(to,s,bs) | to<-langs,
                 let bs = PGF.bracketedLinearize pgf to (transfer to tree)
                     s = unwords $ PGF.flattenBracketedString bs]
  where
    langs = if null to then PGF.languages pgf else to

transfer lang = if "LaTeX" `isSuffixOf` show lang
                then fold -- OpenMath LaTeX transfer
                else id

-- | list all variants and their forms
linearizes' :: PGF -> [PGF.Language] -> PGF.Tree -> [(PGF.Language,[String])]
linearizes' pgf tos tree =
    [(to,lins to (transfer to tree)) | to <- langs]
  where
    langs = if null tos then PGF.languages pgf else tos
    lins to = nub . concatMap (map snd) . PGF.tabularLinearizes pgf to

-- | tabulate all variants and their forms
linearizeTabular
  :: PGF -> [PGF.Language] -> PGF.Tree -> [(PGF.Language,[(String,[String])])]
linearizeTabular pgf tos tree =
    [(to,lintab to (transfer to tree)) | to <- langs]
  where
    langs = if null tos then PGF.languages pgf else tos
    lintab to t = [(p,nub [t|(p',t)<-vs,p'==p])|p<-ps]
      where
        ps = nub (map fst vs)
        vs = concat (PGF.tabularLinearizes pgf to t)

linearizeAndBind pgf mto t =
    [(la, binds s,bs) | (la,s,bs) <- linearize' pgf mto t]
  where
    binds = unwords . bs . words
    bs ws = case ws of
      u:"&+":v:ws2 -> bs ((u ++ v):ws2)
      u:ws2        -> u : bs ws2
      _            -> []

selectLanguage :: PGF -> Maybe (Accept Language) -> PGF.Language
selectLanguage pgf macc = case acceptable of
                            []  -> case PGF.languages pgf of
                                     []  -> error "No concrete syntaxes in PGF grammar."
                                     l:_ -> l
                            Language c:_ -> fromJust (langCodeLanguage pgf c)
  where langCodes = mapMaybe (PGF.languageCode pgf) (PGF.languages pgf)
        acceptable = negotiate (map Language langCodes) macc

langCodeLanguage :: PGF -> String -> Maybe PGF.Language
langCodeLanguage pgf code = listToMaybe [l | l <- PGF.languages pgf, PGF.languageCode pgf l == Just code]

-- * General utilities

f .= v = (f,showJSON v)
f # x = fmap f x
f % x = ap f x

--cleanFilePath :: FilePath -> FilePath
--cleanFilePath = takeFileName
