library(tidyverse)

rm(list=ls())

ud_am <- read.csv('data/parsed_corpora/UD/UD_Amharic/UD_AM_ATT.csv')
logp_sud_am <- read.csv('data/surprisal/SUD/SUD_AM_ATT_logp.csv') %>%
  select(doc_id, sent_id, word_id, word_form, logp)
logp_ud_am <- ud_am %>% inner_join(logp_sud_am) %>% 
  mutate(word_head = as.numeric(word_head))

ud_cn <- read.csv('data/parsed_corpora/UD/UD_Chinese/UD_CN_GSDSimp.csv')
logp_sud_cn <- read.csv('data/surprisal/SUD/SUD_CN_GSDSimp_logp.csv') %>%
  select(sent_id, word_id, word_form, logp)
logp_ud_cn <- ud_cn %>% inner_join(logp_sud_cn) %>% 
  mutate(word_head = as.numeric(word_head))

ud_da <- read.csv('data/parsed_corpora/UD/UD_Danish/UD_DA_DDT.csv')
logp_sud_da <- read.csv('data/surprisal/SUD/SUD_DA_DDT_logp.csv') %>%
  select(sent_id, word_id, word_form, logp)
logp_ud_da <- ud_da %>% inner_join(logp_sud_da) %>% 
  mutate(word_head = as.numeric(word_head))

ud_de <- read.csv('data/parsed_corpora/UD/UD_German/UD_DE_GSD.csv')
logp_sud_de <- read.csv('data/surprisal/SUD/SUD_DE_GSD_logp.csv') %>%
  select(sent_id, word_id, word_form, logp)
logp_ud_de <- ud_de %>% inner_join(logp_sud_de) %>% 
  mutate(word_head = as.numeric(word_head))

ud_en <- read.csv('data/parsed_corpora/UD/UD_English/UD_EN_GUM.csv')
logp_sud_en <- read.csv('data/surprisal/SUD/SUD_EN_GUM_logp.csv') %>%
  select(doc_id, sent_id, word_id, word_form, logp)
logp_ud_en <- ud_en %>% inner_join(logp_sud_en) %>% 
  mutate(word_head = as.numeric(word_head))

ud_es <- read.csv('data/parsed_corpora/UD/UD_Spanish/UD_ES_AnCora.csv')
logp_sud_es <- read.csv('data/surprisal/SUD/SUD_ES_AnCora_logp.csv') %>%
  select(doc_id, sent_id, word_id, word_form, logp)
logp_ud_es <- ud_es %>% inner_join(logp_sud_es) %>% 
  mutate(word_head = as.numeric(word_head))

ud_it <- read.csv('data/parsed_corpora/UD/UD_Italian/UD_IT_ISDT.csv')
logp_sud_it <- read.csv('data/surprisal/SUD/SUD_IT_ISDT_logp.csv') %>%
  select(doc_id, sent_id, word_id, word_form, logp)
logp_ud_it <- ud_it %>% inner_join(logp_sud_it) %>% 
  mutate(word_head = as.numeric(word_head))

ud_ja <- read.csv('data/parsed_corpora/UD/UD_Japanese/UD_JA_GSD.csv')
logp_sud_ja <- read.csv('data/surprisal/SUD/SUD_JA_GSD_logp.csv') %>%
  select(sent_id, word_id, word_form, logp)
logp_ud_ja <- ud_ja %>% inner_join(logp_sud_ja) %>% 
  mutate(word_head = as.numeric(word_head))

ud_ko <- read.csv('data/parsed_corpora/UD/UD_Korean/UD_KO_kaist.csv')
logp_sud_ko <- read.csv('data/surprisal/SUD/SUD_KO_kaist_logp.csv') %>%
  select(doc_id, sent_id, word_id, word_form, logp)
logp_ud_ko <- ud_ko %>% inner_join(logp_sud_ko) %>% 
  mutate(word_head = as.numeric(word_head))

ud_ru <- read.csv('data/parsed_corpora/UD/UD_Russian/UD_RU_SynTagRus.csv')
logp_sud_ru <- read.csv('data/surprisal/SUD/SUD_RU_SynTagRus_logp_small.csv') %>%
  select(doc_id, sent_id, word_id, word_form, logp)
logp_ud_ru <- ud_ru %>% inner_join(logp_sud_ru) %>% 
  mutate(word_head = as.numeric(word_head))

ud_tr <- read.csv('data/parsed_corpora/UD/UD_Turkish/UD_TR_BOUN.csv')
logp_sud_tr <- read.csv('data/surprisal/SUD/SUD_TR_BOUN_logp.csv') %>%
  select(sent_id, word_id, word_form, logp)
logp_ud_tr <- ud_tr %>% inner_join(logp_sud_tr) %>% 
  mutate(word_head = as.numeric(word_head))

write.csv(logp_ud_am, file='Surprisal/UD/UD_AM_ATT_logp.csv', row.names=FALSE)
write.csv(logp_ud_cn, file='Surprisal/UD/UD_CN_GSDSimp_logp.csv', row.names=FALSE)
write.csv(logp_ud_da, file='Surprisal/UD/UD_DA_DDT_logp.csv', row.names=FALSE)
write.csv(logp_ud_de, file='Surprisal/UD/UD_DE_GSD_logp.csv', row.names=FALSE)
write.csv(logp_ud_en, file='Surprisal/UD/UD_EN_GUM_logp.csv', row.names=FALSE)
write.csv(logp_ud_es, file='Surprisal/UD/UD_ES_AnCora_logp.csv', row.names=FALSE)
write.csv(logp_ud_it, file='Surprisal/UD/UD_IT_ISDT_logp.csv', row.names=FALSE)
write.csv(logp_ud_ja, file='Surprisal/UD/UD_JA_GSD_logp.csv', row.names=FALSE)
write.csv(logp_ud_ko, file='Surprisal/UD/UD_KO_kaist_logp.csv', row.names=FALSE)
write.csv(logp_ud_ru, file='Surprisal/UD/UD_RU_SynTagRus_logp_small.csv', row.names=FALSE)
write.csv(logp_ud_tr, file='Surprisal/UD/UD_TR_BOUN_logp.csv', row.names=FALSE)



