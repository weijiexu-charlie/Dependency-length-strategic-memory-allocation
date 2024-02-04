import pandas as pd
import numpy as np

LANGS_DOCbyDOC = ['AM', 'EN', 'ES', 'IT', 'KO', 'RU']
LANGS_SENTbySENT = ['CN', 'DA', 'DE', 'JA', 'TR']

CORPORA_UD = {
	'AM': 'data/surprisal/UD/UD_AM_ATT_logp.csv',
	'CN': 'data/surprisal/UD/UD_CN_GSDSimp_logp.csv',
	'DA': 'data/surprisal/UD/UD_DA_DDT_logp.csv',
	'DE': 'data/surprisal/UD/UD_DE_GSD_logp.csv',
	'EN': 'data/surprisal/UD/UD_EN_GUM_logp.csv',
	'ES': 'data/surprisal/UD/UD_ES_AnCora_logp.csv',
	'IT': 'data/surprisal/UD/UD_IT_ISDT_logp.csv',
	'JA': 'data/surprisal/UD/UD_JA_GSD_logp.csv',
	'KO': 'data/surprisal/UD/UD_KO_kaist_logp.csv',
	'RU': 'data/surprisal/UD/UD_RU_SynTagRus_logp_small.csv',
	'TR': 'data/surprisal/UD/UD_TR_BOUN_logp.csv'
}

OUTPUT_FILE_UD = {
	'AM': 'data/dependencies/UD/dependencies_UD_AM_ATT.csv',
	'CN': 'data/dependencies/UD/dependencies_UD_CN_GSDSimp.csv',
	'DA': 'data/dependencies/UD/dependencies_UD_DA_DDT.csv',
	'DE': 'data/dependencies/UD/dependencies_UD_DE_GSD.csv',
	'EN': 'data/dependencies/UD/dependencies_UD_EN_GUM.csv',
	'ES': 'data/dependencies/UD/dependencies_UD_ES_AnCora.csv',
	'IT': 'data/dependencies/UD/dependencies_UD_IT_ISDT.csv',
	'JA': 'data/dependencies/UD/dependencies_UD_JA_GSD.csv',
	'KO': 'data/dependencies/UD/dependencies_UD_KO_kaist.csv',
	'RU': 'data/dependencies/UD/dependencies_UD_RU_SynTagRus_small.csv',
	'TR': 'data/dependencies/UD/dependencies_UD_TR_BOUN.csv'
}


def transform_flat_structure(sent_df):
	'''
	Merge flat structures and remove punctuations.

	Input:
		sent_df (df): a sentence as pandas dataframe
	'''
	sent_df = sent_df.assign(word_loc = sent_df.word_id)
	sent_df = sent_df.assign(sent_len = sent_df.shape[0])
	flat_words = sent_df.index[sent_df.word_deprel=='flat'].tolist()
	for f in flat_words:
		flat = sent_df.loc[f]
		head_id = sent_df.word_head.loc[f]
		# Just in case iloc is different from loc label
		head_loc = sent_df[sent_df.word_loc==head_id].index[0]
		head = sent_df[sent_df.word_loc==head_id]
		# merge word information for flat structure
		sent_df.at[head_loc, 'word_form'] = ' '.join([head.word_form.iloc[0], flat.word_form])
		if type(head.word_lemma.iloc[0]) != 'str' or type(flat.word_lemma) != 'str':
			sent_df.at[head_loc, 'word_lemma'] = head.word_lemma.iloc[0]
		else:
			sent_df.at[head_loc, 'word_lemma'] = ' '.join([head.word_lemma.iloc[0], flat.word_lemma])
		# Just in case there might be punctuations in flat structures
		sent_df.at[head_loc, 'logp'] = head.logp.iloc[0] + flat.logpcumsum - head.logpcumsum.iloc[0]
		sent_df.at[head_loc, 'word_deprel'] = head.word_deprel.iloc[0]
		sent_df.at[head_loc, 'logpcumsum'] = flat.logpcumsum
		# sent_df.at[head_loc, 'word_loc'] = flat.word_loc    # Seems like UD annotate flat structure differently
		sent_df.at[f, 'sent_id'] = 'to_drop'
	# sent_df = sent_df[sent_df.word_head != 'to_drop']
	# sent_df = sent_df[sent_df.word_upos!='PUNCT']

	return sent_df


def get_dependencies(sent_df):

	# This is for the calculation of dependency length by surprisal later
	sent_df = sent_df.assign(logpcumsum = sent_df.logp.cumsum())
	
	sent_df = transform_flat_structure(sent_df)
	head_df = sent_df[['word_id', 'word_form', 'word_lemma', 'word_upos', 'word_xpos', 'word_morph', 'word_deprel', 'logp', 'logpcumsum']].copy()
	head_df = head_df.assign(head_logpcumsum = head_df.logpcumsum).drop(columns='logpcumsum')
	sent_df = sent_df.assign(dep_logpcumsum = sent_df.logpcumsum).drop(columns='logpcumsum')

	# # Deal with root, need to remove dep_deprel=='root' later
	# root = head_df.tail(1).copy()
	# # print(root.info())
	# root.iloc[0, 0] = 0
	# head_df = pd.concat([head_df, root])
	
	# Sort head_df based on the order of head_ids in sent_df
	sent_df = sent_df[sent_df['word_head'].isin(sent_df['word_id'])]  # In case some word heads are not in the dataframe
	sorter = sent_df['word_head']
	head_df = head_df.set_index('word_id', drop=False)
	head_df = head_df.loc[sorter]

	# Change column names to 'dep' and 'head'
	head_df = head_df.rename(columns={
		'word_id': 'head_id',
		'word_form': 'head_form',
		'word_lemma': 'head_lemma',
		'word_upos': 'head_upos',
		'word_xpos': 'head_xpos',
		'word_morph': 'head_morph',
		'word_deprel': 'head_deprel',
		'logp': 'head_logp'
		}).set_index('head_id', drop=False)
	sent_df = sent_df.rename(columns={
		'word_id': 'dep_id',
		'word_form': 'dep_form',
		'word_lemma': 'dep_lemma',
		'word_upos': 'dep_upos',
		'word_xpos': 'dep_xpos',
		'word_morph': 'dep_morph',
		'word_deprel': 'dep_deprel',
		'logp': 'dep_logp'
		}).set_index('word_head', drop=False)

	sent_df = pd.concat([sent_df, head_df], axis=1).reset_index(drop=True)

	# Get dependency length by word
	sent_df = sent_df.assign(
		dist_byword = sent_df.head_id - sent_df.dep_id,
		dist_byword_abs = abs(sent_df.head_id - sent_df.dep_id),
		)

	sent_df = get_antecedents(sent_df)
	
	# Get dependency length by logp
	sent_df = sent_df.assign(
		dist_bylogp = sent_df.post_logpcumsum - sent_df.post_logp - sent_df.antec_logpcumsum
		)

	return sent_df


def get_antecedents(sent_df):
	'''

	'''
	sent_df = sent_df.assign(
		antec_id = np.where(sent_df.head_id < sent_df.dep_id, sent_df.head_id, sent_df.dep_id),
		antec_form = np.where(sent_df.head_id < sent_df.dep_id, sent_df.head_form, sent_df.dep_form),
		antec_lemma = np.where(sent_df.head_id < sent_df.dep_id, sent_df.head_lemma, sent_df.dep_lemma),
		antec_upos = np.where(sent_df.head_id < sent_df.dep_id, sent_df.head_upos, sent_df.dep_upos),
		antec_xpos = np.where(sent_df.head_id < sent_df.dep_id, sent_df.head_xpos, sent_df.dep_xpos),
		antec_morph = np.where(sent_df.head_id < sent_df.dep_id, sent_df.head_morph, sent_df.dep_morph),
		antec_deprel = np.where(sent_df.head_id < sent_df.dep_id, sent_df.head_deprel, sent_df.dep_deprel),
		antec_logp = np.where(sent_df.head_id < sent_df.dep_id, sent_df.head_logp, sent_df.dep_logp),
		post_logp = np.where(sent_df.head_id > sent_df.dep_id, sent_df.head_logp, sent_df.dep_logp),
		antec_logpcumsum = np.where(sent_df.head_id < sent_df.dep_id, sent_df.head_logpcumsum, sent_df.dep_logpcumsum),
		post_logpcumsum = np.where(sent_df.head_id > sent_df.dep_id, sent_df.head_logpcumsum, sent_df.dep_logpcumsum)
		)
	return sent_df


def main():

	LANGS = LANGS_DOCbyDOC + LANGS_SENTbySENT
	for l in LANGS:
		print('Starting: {}'.format(l))
		corpus = pd.read_csv(CORPORA_UD[l])
		if l in LANGS_DOCbyDOC:
			corpus = corpus.groupby(['doc_id', 'sent_id']).apply(get_dependencies)
		else:
			corpus = corpus.groupby(['sent_id']).apply(get_dependencies)
		corpus = corpus[corpus.sent_id != 'to_drop']
		corpus = corpus[corpus.dep_deprel != 'root']
		corpus = corpus[(corpus.head_upos!='PUNCT') & (corpus.dep_upos!='PUNCT')]
		corpus = corpus.drop(columns=['word_head', 'word_loc', 'dep_logpcumsum', 'head_logpcumsum', 'antec_logpcumsum', 'post_logpcumsum'])
		corpus.to_csv(OUTPUT_FILE_UD[l], index=False)
		print('Finished: {}'.format(l))





