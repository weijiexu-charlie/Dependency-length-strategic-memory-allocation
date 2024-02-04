import pandas as pd
import random
from gpt3query import query
from tokenizations import get_alignments


CORPUS = 'data/parsed_corpora/SUD_EN_GUM.csv'
SEED = 100
OUTPUT_FILE = 'data/surprisal/SUD/SUD_EN_GUM_logp.csv'
OUTPUT_FILE_TEST = 'data/surprisal/SUD/SUD_EN_GUM_logp_test.csv'


corpus = pd.read_csv(CORPUS)

pd.set_option('mode.chained_assignment', None)


def sample_corpus(corpus=corpus, text_num=50, seed=SEED):
	'''
	Get a subset of corpus by sampling based on doc_id
	'''
	docs = corpus['doc_id'].sample(n=text_num, random_state=seed)
	df = corpus[corpus.doc_id.isin(docs)]
	return df


def get_doc_dfs(corpus, max_wnum=1800):
	'''
	Get a list of document texts from corpus for LM.
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
			doc_dfs += split_doc(doc_df)
		else:
			doc_dfs.append(doc_df)
	return doc_dfs


def split_doc(doc_df):
	'''
	If number of words is larger than 1500, split the doc before LM.
	'''
	split_interv = doc_df.shape[0] // 2
	doc1 = doc_df.iloc[:split_interv,]
	doc2 = doc_df.iloc[split_interv:,]
	return [doc1, doc2]


def get_text_4lm(doc_df):
	'''
	Get the plain text of a document to feed into LMs.
	'''
	sents = []
	sent_ids = pd.unique(doc_df.sent_id)
	for s in sent_ids:
		sent = doc_df[doc_df.sent_id==s].text.iloc[0]
		sents.append(sent)
	text = ' '.join(sents)
	return text


def add_text_logp(doc_df):
	'''
	Given a document df, add a column of logp for each corpus token. No return
	'''
	tokens_corpus = doc_df.word_form.tolist()
	text = get_text_4lm(doc_df)
	model_output = get_text_surprisal(text)
	aligned_logp = align_tokenization(tokens_corpus, model_output)
	return doc_df.assign(logp = aligned_logp)


def get_text_surprisal(text):
	'''
	Given text input, return model results as a list of tuples (token, logprob).
	'''
	result = []
	lines = query(text, write_metadata=False)
	lines_iter = iter(lines)
	for line in lines_iter:
		token, logprob = line['token'].strip(), line['logprob']
		result.append((token, logprob))
	return result


def align_tokenization(tokens_corpus, model_output):
	'''
	Align the tokenization between model output and the corpus. Specifically,
	we want the tokenization in the corpus, but align it with model output.
	'''
	result = []
	tokens_lm = [w[0] for w in model_output]
	logprobs = [w[1] for w in model_output]
	corpus2lm, _ = get_alignments(tokens_corpus, tokens_lm)
	for i in corpus2lm: 
		if len(i) == 1:
			logp = logprobs[i[0]]
		elif len(i) == 0:    # irreconcilable alignment
			logp = None
		else:
			if logprobs[i[0]] == None:
				logp = None
			else:
				logp = sum(logprobs[i[0]:i[-1]+1])
		result.append(logp)
	return result


def main(if_test=True, small_corpus=False):
	doc_dfs = get_doc_dfs(corpus)
	if if_test:
		doc_dfs = doc_dfs[47:48]
	df = pd.DataFrame()
	for doc in doc_dfs:
		doc = add_text_logp(doc)
		df = pd.concat([df, doc])
		print('Completed: Document {}'.format(doc.doc_id.iloc[0]))
	if if_test:
		df.to_csv(OUTPUT_FILE_TEST, index=False)
	else:
		df.to_csv(OUTPUT_FILE, index=False)







