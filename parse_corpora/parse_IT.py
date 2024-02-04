
import csv


IT_CORPUS_SUD = 'SUD_2.11/SUD_Italian-ISDT/it_isdt-sud-train.conllu'
OUTPUT_FILE_SUD = 'data/parsed_corpora/SUD/SUD_Italian/SUD_IT_ISDT_raw.csv'

IT_CORPUS_UD = 'UD_2.11/ud-treebanks-v2.11/UD_Italian-ISDT/it_isdt-ud-train.conllu'
OUTPUT_FILE_UD = 'data/parsed_corpora/UD/UD_Italian/UD_IT_ISDT_raw.csv'


def parse_corpus(filename):

	sentences, doc_id = [], 0
	with open(filename, mode='r', encoding='utf-8') as data:
		for line in data:
			if line != '\n':
				if line.startswith('#'):
					if len(line.split('=', 1)) != 2:
						continue
					k, v = line.split('=', 1)
					if k[2:-1] == 'newdoc':
						doc_id += 1
						doc_name, sent_id = v[1:].strip(), 1
					if k[2:-1] == 'text':
						text = v[1:].strip()
					if k[2:-1] == 'sent_id':
						sent_name = v[1:].strip()
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
	corpus_writecsv(OUTPUT_FILE_UD, parse_corpus(IT_CORPUS_UD))








