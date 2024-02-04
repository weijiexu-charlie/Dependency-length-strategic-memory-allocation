import csv


CORPUS_SUD = 'SUD_2.11/SUD_Korean-Kaist/ko_kaist-sud-train.conllu'
OUTPUT_FILE_SUD = 'data/parsed_corpora/SUD/SUD_Korean/SUD_KO_kaist_raw.csv'

CORPUS_UD = 'UD_2.11/ud-treebanks-v2.11/UD_Korean-Kaist/ko_kaist-ud-train.conllu'
OUTPUT_FILE_UD = 'data/parsed_corpora/UD/UD_Korean/UD_KO_kaist_raw.csv'


def parse_corpus(filename):

	sentences, doc_id = [], 0
	with open(filename, mode='r', encoding='utf-8') as data:
		for line in data:
			if line != '\n':
				if line.startswith('#'):
					if len(line.split('=', 1)) != 2:
						continue
					k, v = line.split('=', 1)
					if k[2:-1] == 'sent_id':
						doc_name, sent_name = v[1:].strip().split('-')
						sent_id = int(sent_name[1:])
						if sent_id == 1:
							doc_id += 1
					if k[2:-1] == 'text':
						text = v[1:].strip()
				else:
					word = line.split('\t')
					result = {
						'doc_id': doc_id,
						'sent_id': sent_id,
						'word_id': word[0],
						'word_form': word[1],
						'word_lemma': word[2],
						'word_upos': word[3],
						'word_xpos': word[4],
						'word_morph': word[5],
						'word_head': word[6],
						'word_deprel': word[7],
						'text': text,
						'sent_name': sent_name,
						'doc_name': doc_name
					}
					yield result
			else:    # Sentence boundary: Wrap up the sentence and reset
				sent_id += 1


def corpus_writecsv(filename, data):
	
	data_iter = iter(data)
	first_line = next(data_iter)
	with open(filename, 'w', newline='') as file: 
		writer = csv.DictWriter(file, first_line.keys())
		writer.writeheader()
		writer.writerow(first_line)
		for line in data_iter:
			writer.writerow(line)


def main():
	corpus_writecsv(OUTPUT_FILE_UD, parse_corpus(CORPUS_UD))








