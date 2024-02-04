import csv


CORPUS_SUD = 'SUD_2.11/SUD_Turkish-BOUN/tr_boun-sud-train.conllu'
OUTPUT_FILE_SUD = 'data/parsed_corpora/SUD/SUD_Turkish/SUD_TR_BOUN_raw.csv'

CORPUS_UD = 'UD_2.11/ud-treebanks-v2.11/UD_Turkish-BOUN/tr_boun-ud-train.conllu'
OUTPUT_FILE_UD = 'data/parsed_corpora/UD/UD_Turkish/UD_TR_BOUN_raw.csv'


def parse_corpus(filename):

	sent_id = 0

	with open(filename, mode='r', encoding='utf-8') as data:
		for line in data:
			if line != '\n':
				if line.startswith('#'):
					if len(line.split('=', 1)) != 2:
						continue
					k, v = line.split('=', 1)
					if k[2:-1] == 'sent_id':
						sent_id += 1
						sent_name = v[1:].strip()
					if k[2:-1] == 'text':
						text = v[1:].strip()
				else:
					word = line.split('\t')
					result = {
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
						'sent_name': sent_name
					}
					yield result


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








