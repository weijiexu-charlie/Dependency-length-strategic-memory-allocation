import pandas as pd
import utils
import surprisalGPT3


CORPUS = 'data/parsed_corpora/Turkish/SUD_TR_BOUN.csv'
SEED = 100
OUTPUT_FILE = 'data/surprisal/SUD/Turkish/SUD_TR_BOUN_logp.csv'
OUTPUT_FILE_TEST = 'data/surprisal/SUD/Turkish/SUD_TR_BOUN_logp_test.csv'


pd.set_option('mode.chained_assignment', None)


def get_doc_dfs(corpus):
	'''
	Get a list of document texts from corpus for LM. GSD corpus is sentence
	by sentence, so no need to split texts.
	Input:
		corpus (df): pandas df of corpus
	Return:
		doc_dfs (ls): list of document as df
	'''
	doc_dfs = []
	doc_ids = pd.unique(corpus.sent_id)
	for d in doc_ids:
		doc_df = corpus[corpus.sent_id==d]
		doc_dfs.append(doc_df)
	return doc_dfs


def add_text_logp(doc_df):
	'''
	Given a document df, add a column of logp for each corpus token. No return.
	'''
	tokens_corpus = doc_df.word_form.astype(str).tolist()
	text = doc_df.text.iloc[0]
	model_output = surprisalGPT3.get_text_surprisal(text)
	aligned_logp = utils.align_tokenization(tokens_corpus, model_output)
	return doc_df.assign(logp = aligned_logp)


def main(if_test=True, small_corpus=False, doc_num=300):
	
	corpus = pd.read_csv(CORPUS)
	doc_dfs = get_doc_dfs(corpus)
	if if_test:
		doc_dfs = doc_dfs[2999:3020]
	df = pd.DataFrame()
	for doc in doc_dfs:
		if doc.shape[0] == 1:
			continue
		doc = add_text_logp(doc)
		df = pd.concat([df, doc])
		# print('Completed: Document {}'.format(doc.sent_id.iloc[0]))
		if doc.sent_id.iloc[0] % 20 == 0:
			print('Completed: Document {}'.format(doc.sent_id.iloc[0]))
	if if_test:
		df.to_csv(OUTPUT_FILE_TEST, index=False)
	else:
		df.to_csv(OUTPUT_FILE, index=False)







