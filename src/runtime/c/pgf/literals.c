#include <gu/read.h>
#include <pgf/parser.h>
#include <pgf/literals.h>
#include <wctype.h>

GU_DEFINE_TYPE(PgfLiteralCallback, struct);

GU_DEFINE_TYPE(PgfCallbacksMap, GuMap,
		       gu_type(PgfCncCat), NULL,
		       gu_ptr_type(PgfLiteralCallback), &gu_null_struct);


static bool
pgf_match_string_lit(PgfConcr* concr, PgfItem* item, PgfToken tok,
                     PgfExprProb** out_ep, GuPool *pool)
{
	GuPool* tmp_pool = gu_new_pool();

	size_t lin_idx;
	PgfSequence seq;
	pgf_item_sequence(item, &lin_idx, &seq, tmp_pool);
	gu_assert(lin_idx == 0);

	bool accepted = false;
	int n_syms = gu_seq_length(seq);
	if (n_syms == 0) {
		*out_ep = NULL;
		accepted = true;
	} else if (n_syms == 1) {
		PgfExprProb* ep = gu_new(PgfExprProb, pool);
		ep->prob = 0;

		PgfSymbolKS* sks =
			gu_variant_data(gu_seq_get(seq, PgfSymbol, 0));
		
		PgfExprLit *expr_lit =
			gu_new_variant(PGF_EXPR_LIT,
						   PgfExprLit,
						   &ep->expr, pool);
		PgfLiteralStr *lit_str =
			gu_new_variant(PGF_LITERAL_STR,
						   PgfLiteralStr,
						   &expr_lit->lit, pool);
		lit_str->val = gu_seq_get(sks->tokens, PgfToken, 0);

		*out_ep = ep;
		accepted = false;
	} else {
		*out_ep = NULL;
	}
	
	gu_pool_free(tmp_pool);
	return accepted;
}

static PgfLiteralCallback pgf_string_literal_callback =
  { pgf_match_string_lit } ;



static bool
pgf_match_int_lit(PgfConcr* concr, PgfItem* item, PgfToken tok,
                  PgfExprProb** out_ep, GuPool *pool)
{
	GuPool* tmp_pool = gu_new_pool();

	size_t lin_idx;
	PgfSequence seq;
	pgf_item_sequence(item, &lin_idx, &seq, tmp_pool);
	gu_assert(lin_idx == 0);

	bool accepted = false;
	int n_syms = gu_seq_length(seq);
	if (n_syms == 0) {
		int val;

		*out_ep = NULL;
		accepted = gu_string_to_int(tok, &val);
	} else if (n_syms == 1) {
		PgfSymbolKS* sks =
			gu_variant_data(gu_seq_get(seq, PgfSymbol, 0));
		PgfToken tok = gu_seq_get(sks->tokens, PgfToken, 0);

		int val;
		if (!gu_string_to_int(tok, &val)) {
			*out_ep = NULL;
		} else {
			PgfExprProb* ep = gu_new(PgfExprProb, pool);
			ep->prob = 0;

			PgfExprLit *expr_lit =
				gu_new_variant(PGF_EXPR_LIT,
							   PgfExprLit,
							   &ep->expr, pool);
			PgfLiteralInt *lit_int =
				gu_new_variant(PGF_LITERAL_INT,
							   PgfLiteralInt,
							   &expr_lit->lit, pool);
			lit_int->val = val;

			*out_ep = ep;
		}
		
		accepted = false;
	} else {
		*out_ep = NULL;
	}
	
	gu_pool_free(tmp_pool);
	return accepted;
}

static PgfLiteralCallback pgf_int_literal_callback =
  { pgf_match_int_lit } ;



static bool
pgf_match_float_lit(PgfConcr* concr, PgfItem* item, PgfToken tok,
                    PgfExprProb** out_ep, GuPool *pool)
{
	GuPool* tmp_pool = gu_new_pool();

	size_t lin_idx;
	PgfSequence seq;
	pgf_item_sequence(item, &lin_idx, &seq, tmp_pool);
	gu_assert(lin_idx == 0);

	bool accepted = false;
	int n_syms = gu_seq_length(seq);
	if (n_syms == 0) {
		double val;

		*out_ep = NULL;
		accepted = gu_string_to_double(tok, &val);
	} else if (n_syms == 1) {
		PgfSymbolKS* sks =
			gu_variant_data(gu_seq_get(seq, PgfSymbol, 0));
		PgfToken tok = gu_seq_get(sks->tokens, PgfToken, 0);

		double val;
		if (!gu_string_to_double(tok, &val)) {
			*out_ep = NULL;
		} else {
			PgfExprProb* ep = gu_new(PgfExprProb, pool);
			ep->prob = 0;

			PgfExprLit *expr_lit =
				gu_new_variant(PGF_EXPR_LIT,
							   PgfExprLit,
							   &ep->expr, pool);
			PgfLiteralFlt *lit_flt =
				gu_new_variant(PGF_LITERAL_FLT,
							   PgfLiteralFlt,
							   &expr_lit->lit, pool);
			lit_flt->val = val;

			*out_ep = ep;
		}
		
		accepted = false;
	} else {
		*out_ep = NULL;
	}
	
	gu_pool_free(tmp_pool);
	return accepted;
}

static PgfLiteralCallback pgf_float_literal_callback =
  { pgf_match_float_lit } ;



static bool
pgf_match_name_lit(PgfConcr* concr, PgfItem* item, PgfToken tok,
                   PgfExprProb** out_ep, GuPool *pool)
{
	GuPool* tmp_pool = gu_new_pool();

	size_t lin_idx;
	PgfSequence seq;
	pgf_item_sequence(item, &lin_idx, &seq, tmp_pool);

	gu_assert(lin_idx == 0);

	GuExn* err = gu_new_exn(NULL, gu_kind(type), tmp_pool);
	
	GuString hyp = gu_str_string("-", tmp_pool);
	
	bool iscap = false;
	if (gu_string_eq(tok, hyp)) {
		iscap = true;
	} else if (!gu_string_eq(tok, gu_empty_string)) {
		GuReader* rdr = gu_string_reader(tok, tmp_pool);
		iscap = iswupper(gu_read_ucs(rdr, err));
	}

	size_t n_syms = gu_seq_length(seq);
	if (!iscap && n_syms > 0) {
		GuStringBuf *sbuf = gu_string_buf(tmp_pool);
		GuWriter* wtr = gu_string_buf_writer(sbuf);

		for (size_t i = 0; i < n_syms; i++) {
			if (i > 0)
			  gu_putc(' ', wtr, err);

			PgfSymbol sym = gu_seq_get(seq, PgfSymbol, i);
			gu_assert(gu_variant_tag(sym) == PGF_SYMBOL_KS);
			PgfSymbolKS* sks = gu_variant_data(sym);
			PgfToken tok = gu_seq_get(sks->tokens, PgfToken, 0);

			gu_string_write(tok, wtr, err);
		}

		PgfExprProb* ep = gu_new(PgfExprProb, pool);
		ep->prob = 0;

		PgfExprApp *expr_app =
			gu_new_variant(PGF_EXPR_APP,
			               PgfExprApp,
			               &ep->expr, pool);
		PgfExprFun *expr_fun =
			gu_new_variant(PGF_EXPR_FUN,
			               PgfExprFun,
			               &expr_app->fun, pool);
		expr_fun->fun = gu_str_string("MkSymb", pool);
		PgfExprLit *expr_lit =
			gu_new_variant(PGF_EXPR_LIT,
			               PgfExprLit,
			               &expr_app->arg, pool);
		PgfLiteralStr *lit_str =
			gu_new_variant(PGF_LITERAL_STR,
			               PgfLiteralStr,
			               &expr_lit->lit, pool);
		lit_str->val = gu_string_buf_freeze(sbuf, pool);

		*out_ep = ep;
	} else {
		*out_ep = NULL;
	}

	gu_pool_free(tmp_pool);
	
	return iscap;
}

PgfLiteralCallback pgf_nerc_literal_callback =
  { pgf_match_name_lit } ;


PgfCallbacksMap*
pgf_new_callbacks_map(PgfConcr* concr, GuPool *pool)
{
	int fid;
	PgfCCat* ccat;
	
	PgfCallbacksMap* callbacks = 
		gu_map_type_new(PgfCallbacksMap, pool); 
	
	fid  = -1;
	ccat = gu_map_get(concr->ccats, &fid, PgfCCat*);
	if (ccat != NULL)
		gu_map_put(callbacks, ccat->cnccat, 
		           PgfLiteralCallback*, &pgf_string_literal_callback);

	fid  = -2;
	ccat = gu_map_get(concr->ccats, &fid, PgfCCat*);
	if (ccat != NULL)
		gu_map_put(callbacks, ccat->cnccat, 
		           PgfLiteralCallback*, &pgf_int_literal_callback);

	fid  = -3;
	ccat = gu_map_get(concr->ccats, &fid, PgfCCat*);
	if (ccat != NULL)
		gu_map_put(callbacks, ccat->cnccat, 
		           PgfLiteralCallback*, &pgf_float_literal_callback);

	return callbacks;
}

PgfCCat*
pgf_literal_cat(PgfConcr* concr, PgfLiteral lit)
{
	int fid;

	switch (gu_variant_tag(lit)) {
	case PGF_LITERAL_STR:
		fid = -1;
		break;
	case PGF_LITERAL_INT:
		fid = -2;
		break;
	case PGF_LITERAL_FLT:
		fid = -3;
		break;
	default:
		gu_impossible();
		return NULL;
	}

	return gu_map_get(concr->ccats, &fid, PgfCCat*);
}
