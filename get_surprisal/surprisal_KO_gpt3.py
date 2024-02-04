import pandas as pd
import utils
import surprisalGPT3
from gpt3query import query
from tokenizations import get_alignments


CORPUS = 'data/parsed_corpora/Korean/SUD_KO_kaist.csv'
SEED = 100
OUTPUT_FILE = 'data/surprisal/SUD/Korean/SUD_KO_kaist_logp.csv'
OUTPUT_FILE_TEST = 'data/surprisal/SUD/Korean/SUD_KO_kaist_logp_test.csv'
OUTPUT_FILE_SMALL = 'data/surprisal/SUD/Korean/SUD_KO_kaist_logp_small.csv'


pd.set_option('mode.chained_assignment', None)


def get_doc_dfs(corpus, max_wnum=150, min_wnum=50):
	'''
	Get a list of document texts from corpus for LM.
	Less than 150 and more than 50 words fed into the model.
	Seems like can't take too many words at once for Russian.
	Input:
		corpus (df): pandas df of corpus
	Return:
		doc_dfs (ls): list of document as df
	'''
	doc_dfs = []
	doc_ids = pd.unique(corpus.doc_id)
	for d in doc_ids:
		doc_df = corpus[corpus.doc_id==d]
		if doc_df.shape[0] > max_wnum:
			doc_dfs += split_doc(doc_df, max_wnum, min_wnum)
		else:
			doc_dfs.append(doc_df)
	return doc_dfs


def split_doc(doc_df, max_wnum, min_wnum):
	'''
	max_wnum is the max number of words fed into the model.
	'''
	result = []
	sent_ids = pd.unique(doc_df.sent_id)
	df = pd.DataFrame()
	for s in sent_ids:
		sent = doc_df[doc_df.sent_id==s]
		if df.shape[0] + sent.shape[0] <= max_wnum:
			df = pd.concat([df, sent])
		else:
			result.append(df)
			df = sent
	# deal with the last batch of subtext
	if df.shape[0] <= min_wnum:
		result[-1] = pd.concat([result[-1], df])
	else:
		result.append(df)

	return result


def add_text_logp(doc_df):
	'''
	Given a document df, add a column of logp for each corpus token. No return
	'''
	tokens_corpus = doc_df.word_form.astype(str).tolist()
	text = utils.get_text_4lm(doc_df)
	model_output = surprisalGPT3.get_text_surprisal(text)
	aligned_logp = utils.align_tokenization(tokens_corpus, model_output)
	return doc_df.assign(logp = aligned_logp)


def main(if_test=True, small_corpus=False, doc_num=300):
	
	corpus = pd.read_csv(CORPUS)
	
	if small_corpus:
		corpus = utils.sample_corpus(corpus=corpus, doc_num=doc_num, seed=SEED)
	doc_dfs = get_doc_dfs(corpus)
	if if_test:
		doc_dfs = doc_dfs[:1]

	df = pd.DataFrame()
	doc_to_finish = doc_dfs[0].doc_id.iloc[0]
	for doc in doc_dfs:
		doc = add_text_logp(doc)
		df = pd.concat([df, doc])
		if doc.doc_id.iloc[0] != doc_to_finish:
			print('Completed: Document {}'.format(doc_to_finish))
			doc_to_finish = doc.doc_id.iloc[0]
	print('Completed: Document {}'.format(doc_to_finish))
	
	if if_test:
		df.to_csv(OUTPUT_FILE_TEST, index=False)
	else:
		if small_corpus:
			df.to_csv(OUTPUT_FILE_SMALL, index=False)
		else:
			df.to_csv(OUTPUT_FILE, index=False)







