
function GFGrammar(abstract, concretes) {
	this.abstract = abstract;
	this.concretes = concretes;
}

/* Translates a string from any concrete syntax to all concrete syntaxes. 
   Uses the start category of the grammar.
*/
GFGrammar.prototype.translate = function (input, fromLang, toLang) {
	var outputs = new Object();
	var fromConcs = this.concretes;
	if (fromLang) {
	  fromConcs = new Object();
	  fromConcs[fromLang] = this.concretes[fromLang];
	}
	var toConcs = this.concretes;
	if (toLang) {
	  toConcs = new Object();
	  toConcs[toLang] = this.concretes[toLang];
	}
	for (var c1 in fromConcs) {
		var p = this.concretes[c1].parser;
		if (p) {
			var trees = p.parseString(input, this.abstract.startcat);
			if (trees.length > 0) {
				outputs[c1] = new Array();
				for (var i in trees) {
				        outputs[c1][i] = new Object();
				        for (var c2 in toConcs) {
						outputs[c1][i][c2] = this.concretes[c2].linearize(trees[i]);
					}
				}
			}
		}
  	}
	return outputs;
}


/* ------------------------------------------------------------------------- */
/* ----------------------------- LINEARIZATION ----------------------------- */
/* ------------------------------------------------------------------------- */

/* Extension to the String object */

String.prototype.tag = "";
String.prototype.setTag = function (tag) { this.tag = tag; };

/* Abstract syntax trees */
function Fun(name) {
	this.name = name;
	this.args = copy_arguments(arguments, 1);
}
Fun.prototype.print = function () { return this.show(0); } ;
Fun.prototype.show = function (prec) {
	if (this.isMeta()) {
		if (isUndefined(this.type)) {
			return '?';
		} else {
			var s = '?:' + this.type;
			if (prec > 0) {
				s = "(" + s + ")" ;
			}
			return s;
		}
	} else {
		var s = this.name;
		var cs = this.args;
		for (var i in cs) {
		        s += " " + (isUndefined(cs[i]) ? "undefined" : cs[i].show(1));
		}
		if (prec > 0 && cs.length > 0) {
			s = "(" + s + ")" ;
		}
		return s;
	}
};
Fun.prototype.getArg = function (i) {
	return this.args[i];
};
Fun.prototype.setArg = function (i,c) {
	this.args[i] = c;
};
Fun.prototype.isMeta = function() {
	return this.name == '?';
} ;
Fun.prototype.isComplete = function() {
	if (this.isMeta()) {
		return false;
	} else {
		for (var i in this.args) {
			if (!this.args[i].isComplete()) {
				return false;
			}
		}
		return true;
	}
} ;
Fun.prototype.isLiteral = function() {
  return (/^[\"\d]/).test(this.name);
} ;
Fun.prototype.isEqual = function(obj) {
  if (this.name != obj.name)
    return false;

  for (var i in this.args) {
    if (!this.args[i].isEqual(obj.args[i]))
      return false;
  }
  
  return true;
}

/* Concrete syntax terms */

function Arr() { this.arr = copy_arguments(arguments, 0); }
Arr.prototype.tokens = function() { return this.arr[0].tokens(); };
Arr.prototype.sel = function(i) { return this.arr[i.toIndex()]; };
Arr.prototype.setTag = function(tag) {
	for (var i = 0, j = this.arr.length; i < j; i++) {
		this.arr[i].setTag(tag);
	}
};

function Seq() { this.seq = copy_arguments(arguments, 0); }
Seq.prototype.tokens = function() { 
	var xs = new Array();
	for (var i in this.seq) {
		var ys = this.seq[i].tokens();
		for (var j in ys) {
			xs.push(ys[j]);
		}		
	}
	return xs; 
};
Seq.prototype.setTag = function(tag) {
	for (var i = 0, j = this.seq.length; i < j; i++) {
		this.seq[i].setTag(tag);
	}
};

function Variants() { this.variants = copy_arguments(arguments, 0); }
Variants.prototype.tokens = function() { return this.variants[0].tokens(); };
Variants.prototype.sel = function(i) { return this.variants[0].sel(i); };
Variants.prototype.toIndex = function() { return this.variants[0].toIndex(); };
Variants.prototype.setTag = function(tag) {
	for (var i = 0, j = this.variants.length; i < j; i++) {
		this.variants[i].setTag(tag);
	}
};

function Rp(index,value) { this.index = index; this.value = value; }
Rp.prototype.tokens = function() { return new Array(this.index.tokens()); };
Rp.prototype.sel = function(i) { return this.value.arr[i.toIndex()]; };
Rp.prototype.toIndex = function() { return this.index.toIndex(); };
Rp.prototype.setTag = function(tag) { this.index.setTag(tag) };

function Suffix(prefix,suffix) {
	this.prefix = new String(prefix);
	if (prefix.tag) { this.prefix.tag = prefix.tag; }
	this.suffix = suffix;
};
Suffix.prototype.tokens = function() {
	var xs = this.suffix.tokens();
	for (var i in xs) {
		xs[i] = new String(this.prefix + xs[i]);
		xs[i].setTag(this.prefix.tag);
	}
	return xs;
};
Suffix.prototype.sel = function(i) { return new Suffix(this.prefix, this.suffix.sel(i)); };
Suffix.prototype.setTag = function(tag) { if (!this.prefix.tag) { this.prefix.setTag(tag); } };

function Meta() { }
Meta.prototype.tokens = function() { 
	var newString = new String("?");
	newString.setTag(this.tag);
	return new Array(newString);
};
Meta.prototype.toIndex = function() { return 0; };
Meta.prototype.sel = function(i) { return this; };
Meta.prototype.setTag = function(tag) { if (!this.tag) { this.tag = tag; } };

function Str(value) { this.value = value; }
Str.prototype.tokens = function() {
	var newString = new String(this.value);	
	newString.setTag(this.tag);
	return new Array(newString);
};
Str.prototype.setTag = function(tag) { if (!this.tag) { this.tag = tag; } };

function Int(value) { this.value = value; }
Int.prototype.tokens = function() {
	var newString = new String(this.value.toString());
	newString.setTag(this.tag);
	return new Array(newString);
};
Int.prototype.toIndex = function() { return this.value; };
Int.prototype.setTag = function(tag) { if (!this.tag) { this.tag = tag; } };

/* Type annotation */

function GFAbstract(startcat, types) {
	this.startcat = startcat;
	this.types = types;
}
GFAbstract.prototype.addType = function(fun, args, cat) {
	this.types[fun] = new Type(args, cat);
} ;
GFAbstract.prototype.getArgs = function(fun) {
	return this.types[fun].args;
}
GFAbstract.prototype.getCat = function(fun) {
	return this.types[fun].cat;
};
GFAbstract.prototype.annotate = function(tree, type) {
	if (tree.name == '?') {
		tree.type = type;
	} else {
		var typ = this.types[tree.name];
		for (var i in tree.args) {
			this.annotate(tree.args[i], typ.args[i]);
		}
	}
	return tree;
} ;
GFAbstract.prototype.handleLiterals = function(tree, type) {
	if (tree.name != '?') {
		if (type == "String" || type == "Int" || type == "Float") {
			tree.name = type + "_Literal_" + tree.name;
		} else {
			var typ = this.types[tree.name];
			for (var i in tree.args) {
				this.handleLiterals(tree.args[i], typ.args[i]);
			}
		}
	}
	return tree;
} ;
/* Hack to get around the fact that our SISR doesn't build real Fun objects. */
GFAbstract.prototype.copyTree = function(x) {
	var t = new Fun(x.name);
	if (!isUndefined(x.type)) {
	  t.type = x.type;
	}
	var cs = x.args;
	if (!isUndefined(cs)) {
	  for (var i in cs) {
	    t.setArg(i, this.copyTree(cs[i]));
	  }
	}
	return t;
} ;
GFAbstract.prototype.parseTree = function(str, type) { 
	return this.annotate(this.parseTree_(str.match(/[\w\'\.\"]+|\(|\)|\?|\:/g), 0), type); 
} ;
GFAbstract.prototype.parseTree_ = function(tokens, prec) {
	if (tokens.length == 0 || tokens[0] == ")") { return null; }
	var t = tokens.shift();
	if (t == "(") {
		var tree = this.parseTree_(tokens, 0);
		tokens.shift();
		return tree;
	} else if (t == '?') {
		var tree = this.parseTree_(tokens, 0);
		return new Fun('?');
	} else {
		var tree = new Fun(t);
		if (prec == 0) {
			var c, i;
			for (i = 0; (c = this.parseTree_(tokens, 1)) !== null; i++) {
				tree.setArg(i,c);
			}
		}
		return tree;
	}
} ;

function Type(args, cat) {
	this.args = args;
	this.cat = cat;
}

/* Linearization */

function GFConcrete(flags, rules, parser) {
	this.flags = flags;
	this.rules = rules;
	if (parser) {
		this.parser = parser;
	} else {
		this.parser = undefined;
	}
}
GFConcrete.prototype.rule = function (name, cs) { 
  var r = this.rules[name];
  if (r) {
    return this.rules[name](cs); 
  } else {
    window.alert("Missing rule " + name);
  }
};
GFConcrete.prototype.addRule = function (name, f) { this.rules[name] = f; };
GFConcrete.prototype.lindef = function (cat, v) {	return this.rules[cat]([new Str(v)]); } ;
GFConcrete.prototype.linearize = function (tree) { 
	return this.unlex(this.linearizeToTerm(tree).tokens());
};
GFConcrete.prototype.linearizeToTerm = function (tree) {
	if (tree.isMeta()) {
		if (isUndefined(tree.type)) {
			return new Meta();
		} else {
			return this.lindef(tree.type, tree.name);
		}
	} else {
	    var cs = new Array();
		for (var i in tree.args) {
		  cs.push(this.linearizeToTerm(tree.args[i]));
		}
                if (tree.isLiteral()) {
		  return new Arr(new Str(tree.name));
		} else {
		  return this.rule(tree.name, cs);
		}
	}
};
GFConcrete.prototype.unlex = function (ts) {
	if (ts.length == 0) {
		return "";
	}

	var noSpaceAfter = /^[\(\-\[]/;
	var noSpaceBefore = /^[\.\,\?\!\)\:\;\-\]]/;

	var s = "";
	for (var i = 0; i < ts.length; i++) {
		var t = ts[i];
		var after = i < ts.length-1 ? ts[i+1] : null;
		s += t;
		if (after != null && !t.match(noSpaceAfter) 
				  && !after.match(noSpaceBefore)) {
			s += " ";
		}
	}
	return s;
};
GFConcrete.prototype.tagAndLinearize = function (tree) {
	return this.tagAndLinearizeToTerm(tree, "0").tokens();
};
GFConcrete.prototype.tagAndLinearizeToTerm = function (tree, route) {
	if (tree.isMeta()) {
		if (isUndefined(tree.type)) {
			var newMeta = new Meta();
			newMeta.setTag(route);
			return newMeta;
		} else {
			var newTerm = this.lindef(tree.type, tree.name);
			newTerm.setTag(route);
			return newTerm;
		}
	} else {
	    var cs = new Array();
		for (var i in tree.args) {
		  cs.push(this.tagAndLinearizeToTerm(tree.args[i], route + "-" + i));
		}
		var newTerm = this.rule(tree.name, cs);
		newTerm.setTag(route);
		return newTerm;
	}
};

/* Utilities */

/* from Remedial JavaScript by Douglas Crockford, http://javascript.crockford.com/remedial.html */
function isString(a) { return typeof a == 'string'; }
function isArray(a) { return a && typeof a == 'object' && a.constructor == Array; }
function isUndefined(a) { return typeof a == 'undefined'; }
function isBoolean(a) { return typeof a == 'boolean'; }
function isNumber(a) { return typeof a == 'number' && isFinite(a); }
function isFunction(a) { return typeof a == 'function'; }

function dumpObject (obj) {
	if (isUndefined(obj)) {
		return "undefined";
	} else if (isString(obj)) {
		return '"' + obj.toString() + '"'; // FIXME: escape
	} else if (isBoolean(obj) || isNumber(obj)) {
		return obj.toString();
	} else if (isArray(obj)) {
		var x = "[";
		for (var i in obj) {
			x += dumpObject(obj[i]);
			if (i < obj.length-1) {
				x += ",";
			}
		}
		return x + "]";		
	} else {
		var x = "{";
		for (var y in obj) {
			x += y + "=" + dumpObject(obj[y]) + ";" ;
		}
		return x + "}";
	}
}


function copy_arguments(args, start) {
	var arr = new Array();
	for (var i = 0; i < args.length - start; i++) {
		arr[i] = args[i + start];
	}
	return arr;
}

/* ------------------------------------------------------------------------- */
/* -------------------------------- PARSING -------------------------------- */
/* ------------------------------------------------------------------------- */


function Parser(productions, functions, sequences, startCats, totalCats) {
	this.productions = productions;
    this.functions = functions;
    this.sequences = sequences;
	this.startCats = startCats;
    this.totalCats = totalCats;
    
    for (var fid in productions) {
      for (var i in productions[fid]) {
        var rule = productions[fid][i];
        rule.fun = functions[rule.fun];
      }
    }
    
    for (var i in functions) {
      var fun = functions[i];
      for (var j in fun.lins) {
        fun.lins[j] = sequences[fun.lins[j]];
      }
    }
}
Parser.prototype.showRules = function () {
    var ruleStr = new Array();
	ruleStr.push("");
	for (var i = 0, j = this.rules.length; i < j; i++) {
		ruleStr.push(this.rules[i].show());
	}
	return ruleStr.join("");
};
Parser.prototype.tokenize = function (string) {
    var inToken = false;
    var start, end;
    var tokens = new Array();

    for (var i = 0; i < string.length; i++) {
      if (  string.charAt(i) == ' '       // space
	     || string.charAt(i) == '\f'      // form feed
	     || string.charAt(i) == '\n'      // newline
	     || string.charAt(i) == '\r'      // return
	     || string.charAt(i) == '\t'      // horizontal tab
	     || string.charAt(i) == '\v'      // vertical tab
         || string.charAt(i) == String.fromCharCode(160) // &nbsp;
         ) {
	    if (inToken) {
          end = i-1;
          inToken = false;
          
          tokens.push(string.substr(start,end-start+1));
        }
	  } else {
        if (!inToken) {
          start = i;
          inToken = true;
        }
      }
    }
    
    if (inToken) {
      end = i-1;
      inToken = false;
          
      tokens.push(string.substr(start,end-start+1));
    }
    return tokens;
};
Parser.prototype.parseString = function (string, cat) {
	var tokens = this.tokenize(string);
    
	var ps = new ParseState(this, cat);
	for (var i in tokens) {
		if (!ps.next(tokens[i]))
          return new Array();
	}
	return ps.extractTrees();
};
/**
 * Generate list of suggestions given an input string
 */
Parser.prototype.complete = function (input, cat) {

	// Parameter defaults
	if (input == null) input = "";
	if (cat == null) cat = grammar.abstract.startcat;
	
	// Tokenise input string & remove empty tokens
	tokens = input.trim().split(' ');
	for (var i = tokens.length - 1; i >= 0; i--) {
		if (tokens[i] == "") { tokens.splice(i, 1); }
	}
	
	// Capture last token as it may be partial
	current = tokens.pop();
	if (current == null) current = "";

	// Init parse state objects.
	// ps2 is used for testing whether the final token is parsable or not.
	var ps = new ParseState(this, cat);
	var ps2 = new ParseState(this, cat);
	
	// Iterate over tokens, feed one by one to parser
	for (var i = 0; i < tokens.length ; i++) {
		if (!ps.next(tokens[i])) {
			return new Array(); // Incorrect parse, nothing to suggest
		}
		ps2.next(tokens[i]); // also consume token in ps2
	}
	
	// Attempt to also parse current, knowing it may be incomplete
	if (ps2.next(current)) {
		ps.next(current);
		tokens.push(current);
		current = "";
	}
	delete(ps2); // don't need this anymore
	
	// Parse is successful so far, now get suggestions
	var acc = ps.complete(current);
	
	// Format into just a list of strings & return
	// (I know the multiple nesting looks horrible)
	var suggs = new Array();
	if (acc.value) {
		// Iterate over all acc.value[]
		for (var v = 0; v < acc.value.length; v++) {
			// Iterate over all acc.value[].seq[]
			for (var s = 0; s < acc.value[v].seq.length; s++) {
				if (acc.value[v].seq[s].tokens == null) continue;
				// Iterate over all acc.value[].seq[].tokens
				for (var t = 0; t < acc.value[v].seq[s].tokens.length; t++) {
					suggs.push( acc.value[v].seq[s].tokens[t] );
				}
			}
		}
	}
	
	// Note: return used tokens too
	return { 'consumed' : tokens, 'suggestions' : suggs };
}

// Rule Object Definition

function Rule(fun, args) {
    this.id = "Rule";
	this.fun  = fun;
	this.args = args;
}
Rule.prototype.show = function (cat) {
	var recStr = new Array();
	recStr.push(cat, " -> ", fun.name, " [", this.args, "]");
	return recStr.join("");
};
Rule.prototype.isEqual = function (obj) {
	if (this.id != obj.id || this.fun != obj.fun || this.args.length != obj.args.length)
      return false;
      
    for (var i in this.args) {
      if (this.args[i] != obj.args[i])
        return false;
    }

    return true;
};

// Coerce Object Definition

function Coerce(arg) {
    this.id = "Coerce";
	this.arg = arg;
}
Coerce.prototype.show = function (cat) {
	var recStr = new Array();
	recStr.push(cat, " -> _ [", this.args, "]");
	return recStr.join("");
};

// Const Object Definition

function Const(lit, toks) {
    this.id   = "Const";
	this.lit  = lit;
	this.toks = toks;
}
Const.prototype.show = function (cat) {
	var recStr = new Array();
	recStr.push(cat, " -> ", lit.print());
	return recStr.join("");
};
Const.prototype.isEqual = function (obj) {
	if (this.id != obj.id || this.lit.isEqual(obj.lit) || this.toks.length != obj.toks.length)
      return false;
      
    for (var i in this.toks) {
      if (this.toks[i] != obj.toks[i])
        return false;
    }

    return true;
};

function FFun(name,lins) {
    this.name = name;
    this.lins = lins;
}

// Definition of symbols present in linearization records

// Object to represent argument projections in grammar rules
function Arg(i, label) {
	this.id = "Arg";
	this.i = i;
	this.label = label;
}
Arg.prototype.getId = function () { return this.id; };
Arg.prototype.getArgNum = function () { return this.i };
Arg.prototype.show = function () {
	var argStr = new Array();
	argStr.push(this.i, this.label);
	return argStr.join(".");
};

// Object to represent terminals in grammar rules
function KS() {
	this.id = "KS";
	this.tokens = arguments;
}
KS.prototype.getId = function () { return this.id; };
KS.prototype.show = function () {
	var terminalStr = new Array();
	terminalStr.push('"', this.tokens, '"');
	return terminalStr.join("");
};

// Object to represent pre in grammar rules
function KP(tokens,alts) {
	this.id = "KP";
	this.tokens = tokens;
    this.alts   = alts;
}
KP.prototype.getId = function () { return this.id; };
KP.prototype.show = function () {
	var terminalStr = new Array();
	terminalStr.push('"', this.tokens, '"');
	return terminalStr.join("");
};

function Alt(tokens, prefixes) {
  this.tokens   = tokens;
  this.prefixes = prefixes;
}

// Object to represent pre in grammar rules
function Lit(i,label) {
	this.id = "Lit";
	this.i = i;
	this.label = label;
}
Lit.prototype.getId = function () { return this.id; };
Lit.prototype.show = function () {
	var argStr = new Array();
	argStr.push(this.i, this.label);
	return argStr.join(".");
};

// Parsing

function Trie() {
  this.value = null;
  this.items = new Object();
}
Trie.prototype.insertChain = function(keys,obj) {
  var node = this;
  for (var i in keys) {
    var nnode = node.items[keys[i]];
    if (nnode == null) {
      nnode = new Trie();
      node.items[keys[i]] = nnode;
    }
    node = nnode;
  }
  node.value = obj;
}
Trie.prototype.insertChain1 = function(keys,obj) {
  var node = this;
  for (var i in keys) {
    var nnode = node.items[keys[i]];
    if (nnode == null) {
      nnode = new Trie();
      node.items[keys[i]] = nnode;
    }
    node = nnode;
  }
  if (node.value == null)
    node.value = [obj];
  else
    node.value.push(obj);
}
Trie.prototype.lookup = function(key,obj) {
  return this.items[key];
}
Trie.prototype.isEmpty = function() {
  if (this.value != null)
    return false;
    
  for (var i in this.items) {
    return false;
  }
  
  return true;
}

function ParseState(parser, startCat) {
  this.parser = parser;
  this.startCat = startCat;
  this.items = new Trie();
  this.chart = new Chart(parser);

  var items = new Array();
  
  var fids = parser.startCats[startCat];
  if (fids != null) {
    var fid;
    for (fid = fids.s; fid <= fids.e; fid++) {
      var exProds = this.chart.expandForest(fid);
      for (var j in exProds) {
        var rule = exProds[j];
        var fun  = rule.fun;
        for (var lbl in fun.lins) {
          items.push(new ActiveItem(0,0,rule.fun,fun.lins[lbl],rule.args,fid,lbl));
        }
      }
    }
  }
    
  this.items.insertChain(new Array(), items);
}
ParseState.prototype.next = function (token) {
  var acc = this.items.lookup(token);
  if (acc == null)
    acc = new Trie();

  this.process( this.items.value
              , function (fid) {
                  switch (fid) {
                    case -1: return new Const(new Fun('"'+token+'"'), [token]);                  // String
                    case -2: var x = parseInt(token,10);
                             if (token == "0" || (x != 0 && !isNaN(x)))                      // Integer
                               return new Const(new Fun(token), [token]);
                             else
                               return null;
                    case -3: var x = parseFloat(token);
                             if (token == "0" || token == "0.0" || (x != 0 && !isNaN(x)))    // Float
                               return new Const(new Fun(token), [token]);
                             else
                               return null;
                  }
                  
                  return null;
                }
              , function (tokens, item) {
                  if (tokens[0] == token) {
                    var tokens1 = new Array();
                    var i;
                    for (i = 1; i < tokens.length; i++) {
                      tokens1[i-1] = tokens[i];
                    }
                    acc.insertChain1(tokens1, item);
                  }
                }
              );

  this.items = acc;
  this.chart.shift();
  
  return !this.items.isEmpty();
}
/**
 * For a ParseState and a partial input, return all possible completions
 * Based closely on ParseState.next()
 * currentToken could be empty or a partial string
 */
ParseState.prototype.complete = function (currentToken) {

	// Initialise accumulator for suggestions
	var acc = this.items.lookup(currentToken);
	if (acc == null)
		acc = new Trie();
	
	this.process(
		// Items
		this.items.value,
		
		// Deal with literal categories
		function (fid) {
			// Always return null, as suggested by Krasimir
			return null;
		},
	
		// Takes an array of tokens and populates the accumulator
		function (tokens, item) {
			if (currentToken == "" || tokens[0].indexOf(currentToken) == 0) { //if begins with...
				var tokens1 = new Array();
				for (var i = 1; i < tokens.length; i++) {
					tokens1[i-1] = tokens[i];
				}
				acc.insertChain1(tokens1, item);
			}
		}
	);
	
	// Return matches
	return acc;
}
ParseState.prototype.extractTrees = function() {
  this.process( this.items.value
              , function (fid) {
                  return null;
                }
              , function (tokens, item) {
                }
              );
  
  
  var totalCats = this.parser.totalCats;
  var forest    = this.chart.forest;
      
  function go(fid) {
    if (fid < totalCats) {
      return [new Fun("?")];
    } else {
      var trees = new Array();

      var rules = forest[fid];
      for (var j in rules) {
        var rule = rules[j];
            
        if (rule.id == "Const") {
          trees.push(rule.lit);
        } else {        
          var arg_ix = new Array();
          var arg_ts = new Array();
          for (var k in rule.args) {
            arg_ix[k] = 0;
            arg_ts[k] = go(rule.args[k]);
          }
            
          while (true) {
            var t = new Fun(rule.fun.name);
            for (var k in arg_ts) {
              t.setArg(k,arg_ts[k][arg_ix[k]]);
            }
            trees.push(t);
            
            var i = 0;
            while (i < arg_ts.length) {
              arg_ix[i]++;
              if (arg_ix[i] < arg_ts[i].length)
                break;

              arg_ix[i] = 0;
              i++;                
            }
              
            if (i >= arg_ts.length)
              break;
          }
        }
      }
          
      return trees;
    }
  }

  
  var trees = new Array();
  var fids = this.parser.startCats[this.startCat];
  if (fids != null) {
    var fid0;
    for (fid0 = fids.s; fid0 <= fids.e; fid0++) {
    
      var labels = new Object();
      var rules = this.chart.expandForest(fid0);
      for (var i in rules) {
        for (var lbl in rules[i].fun.lins) {
          labels[lbl] = true;
        }
      }
      
      for (var lbl in labels) {
        var fid = this.chart.lookupPC(fid0,lbl,0);
        var arg_ts = go(fid);
        for (var i in arg_ts) {
          var isMember = false;
          for (var j in trees) {
            if (arg_ts[i].isEqual(trees[j])) {
              isMember = true;
              break;
            }
          }
          
          if (!isMember)
            trees.push(arg_ts[i]);
        }
      }
    }
  }    
  
  return trees;
}
ParseState.prototype.process = function (agenda,literalCallback,tokenCallback) {
  if (agenda != null) {
    while (agenda.length > 0) {
      var item = agenda.pop();
      var lin = item.seq;

      if (item.dot < lin.length) {
        var sym = lin[item.dot];
        switch (sym.id) {
          case "Arg": var fid   = item.args[sym.i];
                      var label = sym.label;

                      var items = this.chart.lookupAC(fid,label);
                      if (items == null) {
                        var rules = this.chart.expandForest(fid);
                        for (var j in rules) {
                          var rule = rules[j];
                          agenda.push(new ActiveItem(this.chart.offset,0,rule.fun,rule.fun.lins[label],rule.args,fid,label));
                        }
                        this.chart.insertAC(fid,label,[item]);
                      } else {
                        var isMember = false;
                        for (var j in items) {
                          if (items[j].isEqual(item)) {
                            isMember = true;
                            break;
                          }
                        }
                        
                        if (!isMember) {
                          items.push(item);
                          
                          var fid2 = this.chart.lookupPC(fid,label,this.chart.offset);
                          if (fid2 != null) {
                            agenda.push(item.shiftOverArg(sym.i,fid2));
                          }
                        }
                      }
                      break;
          case "KS":  tokenCallback(sym.tokens, item.shiftOverTokn());
                      break;
          case "KP":  var pitem = item.shiftOverTokn();
                      tokenCallback(sym.tokens, pitem);
                      for (var i in sym.alts) {
                        var alt = sym.alts[i];
                        tokenCallback(alt.tokens, pitem);
                      }
                      break;
          case "Lit": var fid = item.args[sym.i];
                      var rules = this.chart.forest[fid];
                      if (rules != null) {
                        tokenCallback(rules[0].toks, item.shiftOverTokn());
                      } else {
                        var rule = literalCallback(fid);
                        if (rule != null) {
                          fid = this.chart.nextId++;
                          this.chart.forest[fid] = [rule];
                          tokenCallback(rule.toks,item.shiftOverArg(sym.i,fid));
                        }
                      }
                      break;
        }
      } else {
          var fid = this.chart.lookupPC(item.fid,item.lbl,item.offset);
          if (fid == null) {
            fid = this.chart.nextId++;
            
            var items = this.chart.lookupACo(item.offset,item.fid,item.lbl);
            if (items != null) {
              for (var j in items) {
                var pitem = items[j];
                var i = pitem.seq[pitem.dot].i;
                agenda.push(pitem.shiftOverArg(i,fid));
              }
            }
            
            this.chart.insertPC(item.fid,item.lbl,item.offset,fid);
            this.chart.forest[fid] = [new Rule(item.fun,item.args)];
          } else {
            var labels = this.chart.labelsAC(fid);
            if (labels != null) {
              for (var lbl in labels) {
                agenda.push(new ActiveItem(this.chart.offset,0,item.fun,item.fun.lins[lbl],item.args,fid,lbl));
              }
            }
            
            var rules = this.chart.forest[fid];
            var rule  = new Rule(item.fun,item.args);
              
            var isMember = false;
            for (var j in rules) {
              if (rules[j].isEqual(rule))
                isMember = true;
            }
              
            if (!isMember)
              rules.push(rule);
          }
      }
    }
  }
}

function Chart(parser) {
  this.active      = new Object();
  this.actives     = new Array();
  this.passive     = new Object();
  this.forest      = new Object();
  this.nextId      = parser.totalCats;
  this.offset      = 0;
  
  for (var fid in parser.productions) {
    this.forest[fid] = parser.productions[fid];
  }
}
Chart.prototype.lookupAC = function (fid,label) {
  var tmp = this.active[fid];
  if (tmp == null)
    return null;
  return tmp[label];
}
Chart.prototype.lookupACo = function (offset,fid,label) {
  var tmp;
  
  if (offset == this.offset)
    tmp = this.active[fid];
  else
    tmp = this.actives[offset][fid];

  if (tmp == null)
    return null;

  return tmp[label];
}
Chart.prototype.labelsAC = function (fid) {
  return this.active[fid];
}
Chart.prototype.insertAC = function (fid,label,items) {
  var tmp = this.active[fid];
  if (tmp == null) {
    tmp = new Object();
    this.active[fid] = tmp;
  }
  tmp[label] = items;
}
Chart.prototype.lookupPC = function (fid,label,offset) {
  var key = fid+"."+label+"-"+offset;
  return this.passive[key];
}
Chart.prototype.insertPC = function (fid1,label,offset,fid2) {
  var key = fid1+"."+label+"-"+offset;
  this.passive[key] = fid2;
}
Chart.prototype.shift = function () {
  this.actives.push(this.active);
  this.active  = new Object();
  
  this.passive = new Object();
  
  this.offset++;
}
Chart.prototype.expandForest = function (fid) {
  var rules = new Array();
  var forest = this.forest;
  
  var go = function (rules0) {
             for (var i in rules0) {
               var rule = rules0[i];
               switch (rule.id) {
                 case "Rule":   rules.push(rule); break;
                 case "Coerce": go(forest[rule.arg]); break;
               }
             }
           }

  go(this.forest[fid]);
  return rules;
}

function ActiveItem(offset, dot, fun, seq, args, fid, lbl) {
    this.offset= offset;
    this.dot   = dot;
    this.fun   = fun;
    this.seq   = seq;
    this.args  = args;
    this.fid   = fid;
    this.lbl   = lbl;
}
ActiveItem.prototype.isEqual = function (obj) {
    return (this.offset== obj.offset &&
            this.dot   == obj.dot &&
            this.fun   == obj.fun &&
            this.seq   == obj.seq &&
            this.args  == obj.args &&
            this.fid   == obj.fid &&
            this.lbl   == obj.lbl);
}
ActiveItem.prototype.shiftOverArg = function (i,fid) {
    var nargs = new Array();
    for (var k in this.args) {
      nargs[k] = this.args[k];
    }
    nargs[i] = fid;
    return new ActiveItem(this.offset,this.dot+1,this.fun,this.seq,nargs,this.fid,this.lbl);
}
ActiveItem.prototype.shiftOverTokn = function () {
    return new ActiveItem(this.offset,this.dot+1,this.fun,this.seq,this.args,this.fid,this.lbl);
}