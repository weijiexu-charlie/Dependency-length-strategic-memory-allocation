import pandas as pd

LANGS = ['AM', 'CN', 'DA', 'DE', 'EN', 'ES', 'IT', 'JA', 'KO', 'RU', 'TR']

CORPORA_UD = {
	'AM': 'data/parsed_corpora/UD/UD_Amharic/UD_AM_ATT_raw.csv',
	'CN': 'data/parsed_corpora/UD/UD_Chinese/UD_CN_GSDSimp_raw.csv',
	'DA': 'data/parsed_corpora/UD/UD_Danish/UD_DA_DDT_raw.csv',
	'DE': 'data/parsed_corpora/UD/UD_German/UD_DE_GSD_raw.csv',
	'EN': 'data/parsed_corpora/UD/UD_English/UD_EN_GUM_raw.csv',
	'ES': 'data/parsed_corpora/UD/UD_Spanish/UD_ES_AnCora_raw.csv',
	'IT': 'data/parsed_corpora/UD/UD_Italian/UD_IT_ISDT_raw.csv',
	'JA': 'data/parsed_corpora/UD/UD_Japanese/UD_JA_GSD_raw.csv',
	'KO': 'data/parsed_corpora/UD/UD_Korean/UD_KO_kaist_raw.csv',
	'RU': 'data/parsed_corpora/UD/UD_Russian/UD_RU_SynTagRus_raw.csv',
	'TR': 'data/parsed_corpora/UD/UD_Turkish/UD_TR_BOUN_raw.csv',
}

OUTPUT_FILE_UD = {
	'AM': 'parsed_corpora/UD/UD_Amharic/UD_AM_ATT.csv',
	'CN': 'parsed_corpora/UD/UD_Chinese/UD_CN_GSDSimp.csv',
	'DA': 'parsed_corpora/UD/UD_Danish/UD_DA_DDT.csv',
	'DE': 'parsed_corpora/UD/UD_German/UD_DE_GSD.csv',
	'EN': 'parsed_corpora/UD/UD_English/UD_EN_GUM.csv',
	'ES': 'parsed_corpora/UD/UD_Spanish/UD_ES_AnCora.csv',
	'IT': 'parsed_corpora/UD/UD_Italian/UD_IT_ISDT.csv',
	'JA': 'parsed_corpora/UD/UD_Japanese/UD_JA_GSD.csv',
	'KO': 'parsed_corpora/UD/UD_Korean/UD_KO_kaist.csv',
	'RU': 'parsed_corpora/UD/UD_Russian/UD_RU_SynTagRus.csv',
	'TR': 'parsed_corpora/UD/UD_Turkish/UD_TR_BOUN.csv'
}


def preprocessing():

	for l in LANGS:
		corpus = pd.read_csv(CORPORA_UD[l], keep_default_na=False)
		corpus = corpus.replace("`|’", "'", regex=True)   # Replace apostrophes to avoid unexpected errors in LM
		corpus = corpus[~corpus.word_id.astype(str).str.contains('-')]   # Remove compound word_ids 
		corpus.to_csv(OUTPUT_FILE_UD[l], index=False)







