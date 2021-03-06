/* --- Translations object -------------------------------------------------- */

var tree_icon="../minibar/tree-btn.png";
var alignment_icon="../minibar/align-btn.png";

function Translations(server,opts) {
    this.server=server;

    // Default values for options:
    this.options={
	show_abstract: false,
	abstract_action: null, // action when selecting the abstracy syntax tree
	show_trees: false, // add buttons to show abstract syntax trees,
	                   // parse trees & word alignment
	tree_img_format: "png", // format for trees & alignment images,
	                        // can be "gif", "png" or "svg"
	show_grouped_translations: true,
	to_multiple: true, // allow selection of multiple target languages
	show_brackets: false, // show bracketed string
	translate_limit: 25 // maximum number of parse trees to retrieve
    }

    // Apply supplied options
    if(opts) for(var o in opts) this.options[o]=opts[o];

    this.main=empty("div");
    this.menus=empty("span");

    var tom_opts={id:"to_menu"}
    if(this.options.to_multiple) tom_opts.multiple=true,tom_opts.size=5;
    var tom=this.to_menu=node("select",tom_opts,[]);
    appendChildren(this.menus,[text(" To: "), this.to_menu])
    tom.onchange=bind(this.change_language,this);
    var o=this.options
    if(o.initial_grammar && o.initial_toLangs)
	this.set_toLangs_for(o.initial_grammar,o.initial_toLangs)

    /* // This seems triggers weird scrolling behavior in Firefox and Chrome:
    tom.onmouseover=function() { var n=tom.options.length;
				 tom.size=n<12 ? n : 12; }
    tom.onmouseout=function() { var n=tom.options.length;
				tom.size=n<4 ? n : 4; }
    */
}

Translations.prototype.change_grammar=function(grammar) {
    var t=this
    t.grammar=grammar;

    t.local=mt_local(t.server.current_grammar_url)

    update_language_menu(t.to_menu,grammar);
    insertFirst(t.to_menu,option("All","All"));
    t.to_menu.value="All";
    var toLangs=t.local.get("toLangs")
    if(toLangs && toLangs.length>0) {
	t.toLangs=toLangs
	t.toSet=toSet(toLangs)
	updateMultiMenu(t.to_menu,toLangs)
    }
    else {
	t.toLangs=["All"]
	t.toSet={"All":true}
    }
}

Translations.prototype.clear=function() {
    this.main.innerHTML="";
}

Translations.prototype.set_toLangs_for=function(grammar_url,toLangs) {
    var local=mt_local(grammar_url)
    local.put("toLangs",toLangs)
}

Translations.prototype.change_language=function() {
    var t=this
    t.toLangs=multiMenuSelections(t.to_menu)
    t.toSet=toSet(t.toLangs)
    t.local.put("toLangs",t.toLangs)
    t.get_translations();
}

Translations.prototype.translateFrom=function(current,startcat,lin_action) {
    this.current=current;
    this.startcat=startcat;
    this.lin_action=lin_action;
    this.get_translations();
}

Translations.prototype.get_translations=function() {
    with(this) {
	var c=current;
	var args={from:c.from,input:gf_unlex(c.input),cat:startcat}
	if(options.translate_limit) args.limit=options.translate_limit
	if(options.show_grouped_translations)
	    server.translategroup(args,bind(show_groupedtranslations,this));
	else
	    server.translate(args,bind(show_translations,this));
    }
}

Translations.prototype.target_lang=function() {
    with(this) return langpart(to_menu.value,grammar.name);
}

Translations.prototype.show_translations=function(translationResults) {
    var self=this;
    function tdt(tree_btn,txt,action) {
	if(action) {
	    txt=wrap("span",txt)
	    txt.onclick=action
	}
	return self.options.show_trees ? td([tree_btn,text(" "),txt]) : td(txt)
    }
    function act(lin) {
	return self.lin_action ? function() { self.lin_action(lin) } : null
    }
    function show_lin(tree_btn,lin,tree) {
	function draw_table(lintable) {
	    function draw_texts(texts) {
		return texts.map(function(s) { return wrap("div",text(s)) })
	    }
	    function draw_row(row) {
		return tr([td(text(row.params)),td(draw_texts(row.texts))])
	    } // ▼ ▾
	    return wrap("span",
			[text("▾ "),
			 wrap_class("table","lintable",lintable.map(draw_row))])
	}
	function get_tabular() {
	    var t=this
	    var pa=this.parentNode
	    function show_table(lins) {
		if(lins.length==1) {
		    var ta=draw_table(lins[0].table)
		    replaceNode(ta,t)
		    ta.onclick=function() { replaceNode(t,ta) }
		    t.onclick=function() { replaceNode(ta,t) }
		}
	    }
	    self.server.pgf_call("linearizeTable",{"tree":tree,"to":lin.to},
				 show_table)
	}
	return tdt(tree_btn,text("▸ "+lin.text),get_tabular) // ▶
    }
    with(self) {
	var trans=main;
	//var to=target_lang(); // wrong
	var to=to_menu.value;
	var toLangs=self.toLangs
	var toSet=self.toSet
	var cnt=translationResults.length; // cnt==1 usually
	//trans.translations=translations;
	trans.single_translation=[];
	trans.innerHTML="";
	/*
	  trans.appendChild(wrap("h3",text(cnt<1 ? "No translations?" :
	  cnt>1 ? ""+cnt+" translations:":
	  "One translation:")));
	*/
	for(var p=0;p<cnt;p++) {
	    var tra=translationResults[p];
	    var bra=tra.brackets;
	    if (tra.translations != null) {
		for (q = 0; q < tra.translations.length; q++) {
		    var t = tra.translations[q];
		    var lin=t.linearizations;
		    var tbody=empty("tbody");
		    if(options.show_abstract && t.tree) {
			function abs_act() {
			    self.options.abstract_action(t.tree)
			}
			var abs_hdr = options.abstract_action 
		                      ? title("Edit the syntax tree",
				              button("Abstract",abs_act))
			              : text("Abstract: ")
			tbody.appendChild(
			    tr([th(abs_hdr),
				tdt(node("span",{},
					 [abstree_button(t.tree),
					  alignment_button(t.tree,to=="All",toLangs)]),
				    text(t.tree))]));
		    }
		    for(var i=0;i<lin.length;i++) {
			if(lin[i].to==to && toLangs.length==1)
			    trans.single_translation.push(lin[i].text);
			if(lin[i].to==current.from && lin[i].brackets)
			    bra=lin[i].brackets;
			if(to=="All" || toSet[lin[i].to]) {
			    var langcode=langpart(lin[i].to,grammar.name)
		          //var hdr=text(langcode+": ")
			    var hdr=title("Switch input language to "+langcode,
					  button(langcode,act(lin[i])))
			    //hdr.disabled=lin[i].to==current.from
			    var btn=parsetree_button(t.tree,lin[i].to)
			    tbody.appendChild(
				tr([th(hdr),show_lin(btn,lin[i],t.tree)]));
			}
		    }
		    trans.appendChild(wrap("table",tbody));
		}
	    }
	    else if(tra.typeErrors) {
		    var errs=tra.typeErrors;
		    for(var i=0;i<errs.length;i++)
			trans.appendChild(wrap("pre",text(errs[i].msg)))
	    }
	    if(options.show_brackets)
		trans.appendChild(div_class("brackets",draw_brackets(bra)));

	}
    }
}

Translations.prototype.show_groupedtranslations=function(translationsResult) {
    with(this) {
	var trans=main;
	var to=target_lang();
	//var to=to_menu.value // wrong
	var cnt=translationsResult.length;
	//trans.translations=translationsResult;
	trans.single_translation=[];
	trans.innerHTML="";
	for(var p=0;p<cnt;p++) {
	    var t=translationsResult[p];
	    if(to=="All" || t.to==to) {
		var lin=t.linearizations;
		var tbody=empty("tbody");
		if(to=="All") tbody.appendChild(tr([th(text(t.to+":"))]));
		for(var i=0;i<lin.length;i++) {
		    if(to!="All") trans.single_translation[i]=lin[i].text;
		    tbody.appendChild(tr([td(text(lin[i].text))]));
		    if (lin.length > 1) tbody.appendChild(tr([td(text(lin[i].tree))]));
		}
		trans.appendChild(wrap("table",tbody));
	    }
	}
    }
}

Translations.prototype.abstree_button=function(abs) {
  var f=this.options.tree_img_format;
  var img=this.server.current_grammar_url+"?command=abstrtree&format="+f+"&tree="+encodeURIComponent(abs)
    var btn=tree_button(img,"&nocat=true");
  btn.title="Click to display abstract syntax tree"
  return btn
}

Translations.prototype.alignment_button=function(abs,all,toLangs) {
  var f=this.options.tree_img_format;
  var i=button_img(alignment_icon,function(){toggle_img(i)});
  var to= all ? "" : "&to="+encodeURIComponent(toLangs.join(" "))
  i.title="Click to display word alignment"
  i.other=this.server.current_grammar_url+"?command=alignment&format="+f+"&tree="+encodeURIComponent(abs)+to;
  return i;
}

Translations.prototype.parsetree_button=function(abs,lang) {
  var f=this.options.tree_img_format;
  var img=this.server.current_grammar_url
          +"?command=parsetree&format="+f+"&nodefont=arial"
	  +"&from="+lang+"&tree="+encodeURIComponent(abs);
  var btn=tree_button(img)
  btn.title="Click to display parse tree. Click again to show function names."
  return btn;
}

/* --- Auxiliary functions -------------------------------------------------- */

function mt_local(grammar_url) {
    return appLocalStorage("gf.minibar_translations."+grammar_url+".")
}

function tree_button(img_url,opt) {
    var imgs=[tree_icon,img_url+(opt||"&nofun=true"),img_url]
    var current=0;
    function cycle() {
	current++;
	if(current>=imgs.length) current=0;
	i.src=imgs[current]
    }
    var i=button_img(tree_icon,cycle);
    return i
}

function draw_brackets(b) {
    return b.token
	? span_class("token",text(b.token))
	: node("span",{"class":"brackets",
		       title:(b.fun||"_")+":"+b.cat+" "+b.fid+":"+b.index},
	       b.children.map(draw_brackets))
}
