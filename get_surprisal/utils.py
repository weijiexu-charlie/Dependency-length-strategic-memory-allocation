
import pandas as pd
import random
from tokenizations import get_alignments

SEED = 100

def sample_corpus(corpus, doc_num, seed=SEED):
	'''
	Get a subset of corpus by sampling based on doc_id
	'''
	docs = corpus['doc_id'].sample(n=doc_num, random_state=seed)
	df = corpus[corpus.doc_id.isin(docs)]
	return df


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


def align_tokenization(tokens_corpus, model_output):
	'''
	Align the tokenization between model output and the corpus. Specifically,
	we want the tokenization in the corpus, but align it with model output.
	'''
	result = []
	tokens_lm = [str(w[0]) for w in model_output]
	logprobs = [w[1] for w in model_output]
	corpus2lm, _ = get_alignments(tokens_corpus, tokens_lm) 
	for i in corpus2lm: 
		if len(i) == 1:
			logp = logprobs[i[0]]
		elif len(i) == 0:    # irreconcilable alignment
			logp = None
		else:
			if None in logprobs[i[0]:i[-1]+1]:
				logp = None
			else:
				logp = sum(logprobs[i[0]:i[-1]+1])
		result.append(logp)
	return result