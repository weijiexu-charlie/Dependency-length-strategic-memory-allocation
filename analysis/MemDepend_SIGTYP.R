library(Rmisc)
library(tidyverse)
library(stringr)
library(scales)
library(grid)
library(ggpubr)
library(MASS)
library(lmerTest)
library(lme4)
library(brms)
library(stats)
library(modelr)
library(plotrix)
library(mgcv)
library(hexbin)
library(formattable)

rm(list=ls())

d.am.all <- read.csv('data/dependencies/UD/dependencies_UD_AM_ATT.csv') 
d.cn.all <- read.csv('data/dependencies/UD/dependencies_UD_CN_GSDSimp.csv') 
d.da.all <- read.csv('data/dependencies/UD/dependencies_UD_DA_DDT.csv') 
d.de.all <- read.csv('data/dependencies/UD/dependencies_UD_DE_GSD.csv') 
d.en.all <- read.csv('data/dependencies/UD/dependencies_UD_EN_GUM.csv') 
d.es.all <- read.csv('data/dependencies/UD/dependencies_UD_ES_AnCora.csv') 
d.it.all <- read.csv('data/dependencies/UD/dependencies_UD_IT_ISDT.csv')
d.ja.all <- read.csv('data/dependencies/UD/dependencies_UD_JA_GSD.csv') 
d.ko.all <- read.csv('data/dependencies/UD/dependencies_UD_KO_kaist.csv') 
d.ru.all <- read.csv('data/dependencies/UD/dependencies_UD_RU_SynTagRus_small.csv') 
d.tr.all <- read.csv('data/dependencies/UD/dependencies_UD_TR_BOUN.csv') 

d.am.all %>% filter(sent_len <= 5) %>% nrow()  # 355 removed
d.cn.all %>% filter(sent_len <= 5) %>% nrow()  # 2 removed
d.da.all %>% filter(sent_len <= 5) %>% nrow()  # 691 removed
d.de.all %>% filter(sent_len <= 5) %>% nrow()  # 577 removed
d.en.all %>% filter(sent_len <= 5) %>% nrow()  # 1371 removed
d.es.all %>% filter(sent_len <= 5) %>% nrow()  # 698 removed
d.it.all %>% filter(sent_len <= 5) %>% nrow()  # 1470 removed
d.ja.all %>% filter(sent_len <= 5) %>% nrow()  # 496 removed
d.ko.all %>% filter(sent_len <= 5) %>% nrow()  # 3387 removed
d.ru.all %>% filter(sent_len <= 5) %>% nrow()  # 6417 removed
d.tr.all %>% filter(sent_len <= 5) %>% nrow()  # 2973 removed

nats2bits <- function(df){
  df <- df %>%
    mutate(dep_logp = log2(exp(dep_logp)),
           head_logp = log2(exp(head_logp)),
           antec_logp = log2(exp(antec_logp)),
           post_logp = log2(exp(post_logp)),
           dist_bylogp = log2(exp(dist_bylogp)),
           antec_surprisal = -antec_logp)
  df
}

data_wrangling <- function(df, language){
  df <- df %>%
    nats2bits() %>%
    filter(head_logp > -20) %>%
    filter(dep_logp > -20) %>%
    filter(sent_len > 5) %>%
    mutate(abs_dist = dist_byword_abs - 1,
           antec_form = as.factor(antec_form),
           antec_deprel = as.factor(antec_deprel),
           dep_deprel = as.factor(dep_deprel),
           dep_upos = as.factor(dep_upos),
           sent_nchar = as.numeric(nchar(text)),
           sent_len = as.numeric(sent_len),
           antec_surprisal.s = scale(antec_surprisal),
           sent_pos.s = scale(sent_id),
           head_id.s = scale(head_id),
           antec_id.s = scale(antec_id),
           sent_len.s = scale(sent_len),
           dist_bylogp.s = scale(dist_bylogp),
           info_rate = -dist_bylogp/abs_dist,
           info_rate.s = scale(-dist_bylogp/abs_dist),
           language = language) %>%
    dplyr::select(language, dep_form, head_form, sent_pos.s, antec_id.s, 
                  sent_len.s, antec_surprisal, antec_surprisal.s, abs_dist, 
                  dist_bylogp, dep_deprel, dep_upos, head_upos)
  df
}

d.am <- d.am.all %>% data_wrangling('Amharic (AM)')
d.cn <- d.cn.all %>% data_wrangling('Mandarin (CN)')
d.da <- d.da.all %>% data_wrangling('Danish (DA)')
d.de <- d.de.all %>% data_wrangling('German (DE)')
d.en <- d.en.all %>% data_wrangling('English (EN)')
d.es <- d.es.all %>% data_wrangling('Spanish (ES)')   
d.it <- d.it.all %>% data_wrangling('Italian (IT)')
d.ja <- d.ja.all %>% data_wrangling('Japanese (JA)')
d.ko <- d.ko.all %>% data_wrangling('Korean (KO)')
d.ru <- d.ru.all %>% data_wrangling('Russian (RU)')
d.tr <- d.tr.all %>% data_wrangling('Turkish (TR)')

d.all <- d.am %>% rbind(d.cn) %>% rbind(d.da) %>%  rbind(d.de) %>% 
  rbind(d.en) %>% rbind(d.es) %>% rbind(d.it) %>% rbind(d.ja) %>% 
  rbind(d.ko) %>% rbind(d.ru) %>% rbind(d.tr)

d.subj <- d.all %>% filter(dep_deprel%in%c('nsubj', 'csubj'))
d.obj <- d.all %>% filter(dep_deprel%in%c('obj', 'iobj', 'ccomp', 'xcomp'))


filter(d.subj, language=='Amharic (AM)') %>% nrow()
filter(d.subj, language=='Danish (DA)') %>% nrow()
filter(d.subj, language=='English (EN)') %>% nrow()
filter(d.subj, language=='German (DE)') %>% nrow()
filter(d.subj, language=='Italian (IT)') %>% nrow()
filter(d.subj, language=='Japanese (JA)') %>% nrow()
filter(d.subj, language=='Korean (KO)') %>% nrow()
filter(d.subj, language=='Mandarin (CN)') %>% nrow()
filter(d.subj, language=='Russian (RU)') %>% nrow()
filter(d.subj, language=='Spanish (ES)') %>% nrow()
filter(d.subj, language=='Turkish (TR)') %>% nrow()

filter(d.obj, language=='Amharic (AM)') %>% nrow()
filter(d.obj, language=='Danish (DA)') %>% nrow()
filter(d.obj, language=='English (EN)') %>% nrow()
filter(d.obj, language=='German (DE)') %>% nrow()
filter(d.obj, language=='Italian (IT)') %>% nrow()
filter(d.obj, language=='Japanese (JA)') %>% nrow()
filter(d.obj, language=='Korean (KO)') %>% nrow()
filter(d.obj, language=='Mandarin (CN)') %>% nrow()
filter(d.obj, language=='Russian (RU)') %>% nrow()
filter(d.obj, language=='Spanish (ES)') %>% nrow()
filter(d.obj, language=='Turkish (TR)') %>% nrow()


################# Plots #################

meanplot_word = function(d, num_bins, alpha=.02, stat_method='lm') {
  d %>%
    mutate(surp_bin=cut_interval(antec_surprisal, num_bins)) %>%
    group_by(language, surp_bin) %>%
    summarise(antec_surprisal=mean(antec_surprisal),
              m=mean(abs_dist),
              se=std.error(abs_dist),
              upper=m+1.96*se,
              lower=m-1.96*se) %>%
    ungroup() %>%
    ggplot(aes(x=antec_surprisal, y=m, ymin=lower, ymax=upper)) + 
    #geom_point(data=d, aes(x=-logp/log(2), y=rt, ymin=0, ymax=0), alpha=alpha, color="darkblue") +
    stat_smooth(color="red", method=stat_method) +
    geom_errorbar(color="blue") + 
    geom_point(color="black") + 
    theme_bw() +
    ylab("Dependency length (words)") +
    xlab("Antecedent Surprisal (bits)") 
}

meanplot_logp = function(d, num_bins, alpha=.02, stat_method='lm') {
  d %>%
    mutate(surp_bin=cut_interval(antec_surprisal, num_bins)) %>%
    group_by(language, surp_bin) %>%
    summarise(antec_surprisal=mean(antec_surprisal),
              m=mean(-dist_bylogp),
              se=std.error(-dist_bylogp),
              upper=m+1.96*se,
              lower=m-1.96*se) %>%
    ungroup() %>%
    ggplot(aes(x=antec_surprisal, y=m, ymin=lower, ymax=upper)) + 
    #geom_point(data=d, aes(x=-logp/log(2), y=rt, ymin=0, ymax=0), alpha=alpha, color="darkblue") +
    stat_smooth(color="red", method=stat_method) +
    geom_errorbar(color="blue") + 
    geom_point(color="black") + 
    theme_bw() +
    ylab("Dependency length (surprisal)") +
    xlab("Antecedent Surprisal (bits)") 
}

meanplot.word.all <- d.all %>%
  meanplot_word(num_bins=25, stat_method='lm') +
  ggtitle('Dependencies with all types of relations') +
  theme(plot.title = element_text(size=10)) +
  facet_wrap(~language, ncol=6, scale="free_y")
meanplot.word.all

meanplot.word.subj <- d.subj %>%
  meanplot_word(num_bins=25, stat_method='lm') +
  ggtitle('Dependencies with subject relations') +
  theme(plot.title = element_text(size=10)) +
  facet_wrap(~language, ncol=6, scale="free_y")
meanplot.word.subj

meanplot.word.obj <- d.obj %>%
  meanplot_word(num_bins=25, stat_method='lm') +
  ggtitle('Dependencies with object relations') +
  theme(plot.title = element_text(size=10)) +
  facet_wrap(~language, ncol=6, scale="free_y")
meanplot.word.obj

meanplot.bylogp.all <- d.all %>%
  meanplot_logp(num_bins=25, stat_method='lm') +
  ggtitle('Dependencies with all types of relations') +
  theme(plot.title = element_text(size=10)) +
  facet_wrap(~language, ncol=6, scale="free_y")
meanplot.bylogp.all

meanplot.bylogp.subj <- d.subj %>%
  meanplot_logp(num_bins=25, stat_method='lm') +
  ggtitle('Dependencies with subject relations') +
  theme(plot.title = element_text(size=10)) +
  facet_wrap(~language, ncol=6, scale="free_y")
meanplot.bylogp.subj

meanplot.bylogp.obj <- d.obj %>%
  meanplot_logp(num_bins=25, stat_method='lm') +
  ggtitle('Dependencies with object relations') +
  theme(plot.title = element_text(size=10)) +
  facet_wrap(~language, ncol=6, scale="free_y")
meanplot.bylogp.obj

p.all <- ggarrange(meanplot.word.all, meanplot.bylogp.all,
                      labels = c("A", "B"),
                      ncol = 1, nrow = 2)
pdf("plots/SIGTYP.all.pdf", width = 10, height = 6)
p.all
dev.off()

p.subj <- ggarrange(meanplot.word.subj, meanplot.bylogp.subj,
                   labels = c("A", "B"),
                   ncol = 1, nrow = 2)
pdf("plots/SIGTYP.subj.pdf", width = 10, height = 6)
p.subj
dev.off()

p.obj <- ggarrange(meanplot.word.obj, meanplot.bylogp.obj,
                    labels = c("A", "B"),
                    ncol = 1, nrow = 2)
pdf("plots/SIGTYP.obj.pdf", width = 10, height = 6)
p.obj
dev.off()

p.big <- ggarrange(meanplot.word.all, meanplot.bylogp.all,
                   meanplot.word.subj, meanplot.bylogp.subj,
                   meanplot.word.obj, meanplot.bylogp.obj,
                   labels = c("A", "B", "C", "D", "E", "F"),
                   ncol = 2, nrow = 3)
pdf("plots/SIGTYP.big.pdf", width = 13.5, height = 7.8)
p.big
dev.off()


p.byword <- ggarrange(meanplot.word.all, 
                      meanplot.word.subj, 
                      meanplot.word.obj,
                  labels = c("A", "B", "C"),
                  ncol = 1, nrow = 3, widths=c(1, 1, 1), heights = c(1, 1, 1))
pdf("plots/SIGTYP.byword.pdf", width = 12, height = 8.8)
p.byword
dev.off()

p.bylogp <- ggarrange(meanplot.bylogp.all, 
                      meanplot.bylogp.subj, 
                      meanplot.bylogp.obj,
                      labels = c("A", "B", "C"),
                      ncol = 1, nrow = 3, widths=c(1, 1, 1), heights = c(1, 1, 1))
pdf("plots/SIGTYP.bylogp.pdf", width = 12, height = 9)
p.bylogp
dev.off()


################# Stats Models: L as word counts #################

#---------- All dependencies ----------
# Results:
# Positive: Danish, German, English, Spanish, Italian
# Negative: Korean
# Non-Sign: Amharic, Mandarin, Japanese, Russian, Turkish

lmer.am <- lmer(abs_dist ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s +
                  (antec_surprisal.s|dep_deprel),
                data=filter(d.all, language=='Amharic (AM)'))
summary(lmer.am)    # n.s. p=0.175

lmer.da <- lmer(abs_dist ~ antec_id.s + sent_len.s + antec_surprisal.s + 
                  (antec_surprisal.s|dep_deprel), 
                data=filter(d.all, language=='Danish (DA)'))   
summary(lmer.da)    # +; p=0.025 *

lmer.en <- lmer(abs_dist ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s +
                  (antec_surprisal.s|dep_deprel),
                data=filter(d.all, language=='English (EN)'))
summary(lmer.en)    # +; p=0.000885 ***

lmer.de <- lmer(abs_dist ~ antec_id.s + sent_len.s + antec_surprisal.s + 
                  (1|dep_deprel), 
                data=filter(d.all, language=='German (DE)'))    # maximal converging
summary(lmer.de)    # +; p=0.0364 *

lmer.it <- lmer(abs_dist ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s + 
                  (1|dep_deprel),    # maximal converging
                data=filter(d.all, language=='Italian (IT)'))        
summary(lmer.it)    # +; p=9.35e-12 ***

lmer.ja <- lmer(abs_dist ~ antec_id.s + sent_len.s + antec_surprisal.s + 
                  (antec_surprisal.s|dep_deprel),    
                data=filter(d.all, language=='Japanese (JA)'))        
summary(lmer.ja)    # n.s. p=0.416498

lmer.ko <- lmer(abs_dist ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s + 
                  (antec_surprisal.s|dep_deprel),    
                data=filter(d.all, language=='Korean (KO)'))        
summary(lmer.ko)    # -; 0.0219 *

lmer.cn <- lmer(abs_dist ~ antec_id.s + sent_len.s + antec_surprisal.s + 
                  (antec_surprisal.s|dep_deprel),    
                data=filter(d.all, language=='Mandarin (CN)'))        
summary(lmer.cn)    # n.s. p=0.0617 .

lmer.ru <- lmer(abs_dist ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s + 
                  (antec_surprisal.s|dep_deprel), 
                data=filter(d.all, language=='Russian (RU)'))        
summary(lmer.ru)    # n.s. p=0.39532

lmer.es <- lmer(abs_dist ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s + 
                  (antec_surprisal.s|dep_deprel), 
                data=filter(d.all, language=='Spanish (ES)'))        
summary(lmer.es)    # +; p=0.00296 ** 

lmer.tr <- lmer(abs_dist ~ antec_id.s + sent_len.s + antec_surprisal.s + 
                  (antec_surprisal.s|dep_deprel), 
                data=filter(d.all, language=='Turkish (TR)'))        
summary(lmer.tr)    # n.s. p=0.161


#---------- Dependencies with Subj ----------
# Results:
# Positive: Amharic, Mandarin, Danish, English, Spanish, Italian, Russian,
# Negative: German, Turkish
# Non-Sign: Japanese, Korean

lm.subj.am <- lm(abs_dist ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s,
                     data=filter(d.subj, language=='Amharic (AM)'))
summary(lm.subj.am)    # +; p=0.0213 *

lm.subj.da <- lm(abs_dist ~ antec_id.s + sent_len.s + antec_surprisal.s,
                     data=filter(d.subj, language=='Danish (DA)'))
summary(lm.subj.da)    # +; p=2.86e-07 ***

lm.subj.en <- lm(abs_dist ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s,
                 data=filter(d.subj, language=='English (EN)'))
summary(lm.subj.en)    # +; p< 2e-16 ***

lm.subj.de <- lm(abs_dist ~ antec_id.s + sent_len.s + antec_surprisal.s,
                 data=filter(d.subj, language=='German (DE)'))
summary(lm.subj.de)    # -; p<2e-16 ***

lm.subj.it <- lm(abs_dist ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s,
                 data=filter(d.subj, language=='Italian (IT)'))
summary(lm.subj.it)    # +; p<2e-16 ***

lm.subj.ja <- lm(abs_dist ~ antec_id.s + sent_len.s + antec_surprisal.s,
                 data=filter(d.subj, language=='Japanese (JA)'))
summary(lm.subj.ja)    # n.s. p=0.0882 .

lm.subj.ko <- lm(abs_dist ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s,
                 data=filter(d.subj, language=='Korean (KO)'))
summary(lm.subj.ko)    # n.s. p=0.0718 .

lm.subj.cn <- lm(abs_dist ~ antec_id.s + sent_len.s + antec_surprisal.s,
                 data=filter(d.subj, language=='Mandarin (CN)'))
summary(lm.subj.cn)    # +; p=0.0292 *

lm.subj.ru <- lm(abs_dist ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s,
                 data=filter(d.subj, language=='Russian (RU)'))
summary(lm.subj.ru)    # +; p< 2e-16 ***

lm.subj.es <- lm(abs_dist ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s,
                 data=filter(d.subj, language=='Spanish (ES)'))
summary(lm.subj.es)    # +; p< 2e-16 ***

lm.subj.tr <- lm(abs_dist ~ antec_id.s + sent_len.s + antec_surprisal.s,
                 data=filter(d.subj, language=='Turkish (TR)'))
summary(lm.subj.tr)    # -; p=0.0236 *


#---------- Dependencies with Obj ----------
# Results:
# Positive: NA
# Negative: Amharic, Mandarin, German, Korean, Russian
# Non-Sign: Danish, English, Spanish, Italian, Japanese, Turkish

lm.obj.am <- lm(abs_dist ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s,
                 data=filter(d.obj, language=='Amharic (AM)'))
summary(lm.obj.am)    # -; p=0.048 *

lm.obj.da <- lm(abs_dist ~ antec_id.s + sent_len.s + antec_surprisal.s,
                 data=filter(d.obj, language=='Danish (DA)'))
summary(lm.obj.da)    # n.s. p=0.447

lm.obj.en <- lm(abs_dist ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s,
                 data=filter(d.obj, language=='English (EN)'))
summary(lm.obj.en)    # n.s. p=0.7428

lm.obj.de <- lm(abs_dist ~ antec_id.s + sent_len.s + antec_surprisal.s,
                data=filter(d.obj, language=='German (DE)'))
summary(lm.obj.de)    # -; p=1.38e-07 ***

lm.obj.it <- lm(abs_dist ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s,
                 data=filter(d.obj, language=='Italian (IT)'))
summary(lm.obj.it)    # n.s. p=0.0928 . 

lm.obj.ja <- lm(abs_dist ~ antec_id.s + sent_len.s + antec_surprisal.s,
                 data=filter(d.obj, language=='Japanese (JA)'))
summary(lm.obj.ja)    # n.s. p=0.21

lm.obj.ko <- lm(abs_dist ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s,
                 data=filter(d.obj, language=='Korean (KO)'))
summary(lm.obj.ko)    # -; p<2e-16 ***

lm.obj.cn <- lm(abs_dist ~ antec_id.s + sent_len.s + antec_surprisal.s,
                data=filter(d.obj, language=='Mandarin (CN)'))
summary(lm.obj.cn)    # -; p=0.00574 **

lm.obj.ru <- lm(abs_dist ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s,
                 data=filter(d.obj, language=='Russian (RU)'))
summary(lm.obj.ru)    # -; p=1.17e-07 ***

lm.obj.es <- lm(abs_dist ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s,
                data=filter(d.obj, language=='Spanish (ES)'))
summary(lm.obj.es)    # n.s. p=0.0580 . 

lm.obj.tr <- lm(abs_dist ~ antec_id.s + sent_len.s + antec_surprisal.s,
                 data=filter(d.obj, language=='Turkish (TR)'))
summary(lm.obj.tr)    # n.s. p=0.384



################# Stats Models: L as surprisal #################

#---------- All dependencies ----------

lmer.am.logp <- lmer(-dist_bylogp ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s +
                  (antec_surprisal.s|dep_deprel),
                data=filter(d.all, language=='Amharic (AM)'))
summary(lmer.am.logp)    # +; p=0.0109 *

lmer.da.logp <- lmer(-dist_bylogp ~ antec_id.s + sent_len.s + antec_surprisal.s + 
                  (antec_surprisal.s|dep_deprel), 
                data=filter(d.all, language=='Danish (DA)'))   
summary(lmer.da.logp)    # +; 0.00607 **

lmer.en.logp <- lmer(-dist_bylogp ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s +
                  (antec_surprisal.s|dep_deprel),
                data=filter(d.all, language=='English (EN)'))
summary(lmer.en.logp)    # +; p=2.79e-07 ***

lmer.de.logp <- lmer(-dist_bylogp ~ antec_id.s + sent_len.s + antec_surprisal.s + 
                  (antec_surprisal.s|dep_deprel), 
                data=filter(d.all, language=='German (DE)'))  
summary(lmer.de.logp)    # +; p=0.0284 *

lmer.it.logp <- lmer(-dist_bylogp ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s + 
                  (1|dep_deprel),    # maximal converging
                data=filter(d.all, language=='Italian (IT)'))        
summary(lmer.it.logp)    # +; p< 2e-16 ***

lmer.ja.logp <- lmer(-dist_bylogp ~ antec_id.s + sent_len.s + antec_surprisal.s + 
                  (antec_surprisal.s|dep_deprel),    
                data=filter(d.all, language=='Japanese (JA)'))        
summary(lmer.ja.logp)    # n.s. p=0.77490

lmer.ko.logp <- lmer(-dist_bylogp ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s + 
                  (antec_surprisal.s|dep_deprel),    
                data=filter(d.all, language=='Korean (KO)'))        
summary(lmer.ko.logp)    # -; 0.02469 *

lmer.cn.logp <- lmer(-dist_bylogp ~ antec_id.s + sent_len.s + antec_surprisal.s + 
                  (antec_surprisal.s|dep_deprel),    
                data=filter(d.all, language=='Mandarin (CN)'))        
summary(lmer.cn.logp)    # n.s. p=0.331

lmer.ru.logp <- lmer(-dist_bylogp ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s + 
                  (antec_surprisal.s|dep_deprel), 
                data=filter(d.all, language=='Russian (RU)'))        
summary(lmer.ru.logp)    # n.s. p=0.0501 .

lmer.es.logp <- lmer(-dist_bylogp ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s + 
                  (antec_surprisal.s|dep_deprel), 
                data=filter(d.all, language=='Spanish (ES)'))        
summary(lmer.es.logp)    # +; p=0.00042 *** 

lmer.tr.logp <- lmer(-dist_bylogp ~ antec_id.s + sent_len.s + antec_surprisal.s + 
                  (antec_surprisal.s|dep_deprel), 
                data=filter(d.all, language=='Turkish (TR)'))        
summary(lmer.tr.logp)    # n.s. p=0.784


#---------- Dependencies with Subj ----------

lm.subj.am.logp <- lm(-dist_bylogp ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s,
                 data=filter(d.subj, language=='Amharic (AM)'))
summary(lm.subj.am.logp)    # n.s. p=0.186

lm.subj.da.logp <- lm(-dist_bylogp ~ antec_id.s + sent_len.s + antec_surprisal.s,
                 data=filter(d.subj, language=='Danish (DA)'))
summary(lm.subj.da.logp)    # +; p=2.37e-08 ***

lm.subj.en.logp <- lm(-dist_bylogp ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s,
                 data=filter(d.subj, language=='English (EN)'))
summary(lm.subj.en.logp)    # +; p< 2e-16 ***

lm.subj.de.logp <- lm(-dist_bylogp ~ antec_id.s + sent_len.s + antec_surprisal.s,
                 data=filter(d.subj, language=='German (DE)'))
summary(lm.subj.de.logp)    # -; p<2e-16 ***

lm.subj.it.logp <- lm(-dist_bylogp ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s,
                 data=filter(d.subj, language=='Italian (IT)'))
summary(lm.subj.it.logp)    # +; p<2e-16 ***

lm.subj.ja.logp <- lm(-dist_bylogp ~ antec_id.s + sent_len.s + antec_surprisal.s,
                 data=filter(d.subj, language=='Japanese (JA)'))
summary(lm.subj.ja.logp)    # n.s. p=0.985

lm.subj.ko.logp <- lm(-dist_bylogp ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s,
                 data=filter(d.subj, language=='Korean (KO)'))
summary(lm.subj.ko.logp)    # n.s. p=0.156

lm.subj.cn.logp <- lm(-dist_bylogp ~ antec_id.s + sent_len.s + antec_surprisal.s,
                 data=filter(d.subj, language=='Mandarin (CN)'))
summary(lm.subj.cn.logp)    # +; p=0.00202 **

lm.subj.ru.logp <- lm(-dist_bylogp ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s,
                 data=filter(d.subj, language=='Russian (RU)'))
summary(lm.subj.ru.logp)    # +; p< 2e-16 ***

lm.subj.es.logp <- lm(-dist_bylogp ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s,
                 data=filter(d.subj, language=='Spanish (ES)'))
summary(lm.subj.es.logp)    # +; p< 2e-16 ***

lm.subj.tr.logp <- lm(-dist_bylogp ~ antec_id.s + sent_len.s + antec_surprisal.s,
                 data=filter(d.subj, language=='Turkish (TR)'))
summary(lm.subj.tr.logp)    # n.s. p=0.59


#---------- Dependencies with Obj ----------

lm.obj.am.logp <- lm(-dist_bylogp ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s,
                data=filter(d.obj, language=='Amharic (AM)'))
summary(lm.obj.am.logp)    # n.s. p=0.876 

lm.obj.da.logp <- lm(-dist_bylogp ~ antec_id.s + sent_len.s + antec_surprisal.s,
                data=filter(d.obj, language=='Danish (DA)'))
summary(lm.obj.da.logp)    # +; p=0.0427 *

lm.obj.en.logp <- lm(-dist_bylogp ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s,
                data=filter(d.obj, language=='English (EN)'))
summary(lm.obj.en.logp)    # +; p=3.31e-07 ***

lm.obj.de.logp <- lm(-dist_bylogp ~ antec_id.s + sent_len.s + antec_surprisal.s,
                data=filter(d.obj, language=='German (DE)'))
summary(lm.obj.de.logp)    # -; p=0.000223 ***

lm.obj.it.logp <- lm(-dist_bylogp ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s,
                data=filter(d.obj, language=='Italian (IT)'))
summary(lm.obj.it.logp)    # + p=2.03e-06 *** 

lm.obj.ja.logp <- lm(-dist_bylogp ~ antec_id.s + sent_len.s + antec_surprisal.s,
                data=filter(d.obj, language=='Japanese (JA)'))
summary(lm.obj.ja.logp)    # n.s. p=0.94

lm.obj.ko.logp <- lm(-dist_bylogp ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s,
                data=filter(d.obj, language=='Korean (KO)'))
summary(lm.obj.ko.logp)    # -; p<2e-16 ***

lm.obj.cn.logp <- lm(-dist_bylogp ~ antec_id.s + sent_len.s + antec_surprisal.s,
                data=filter(d.obj, language=='Mandarin (CN)'))
summary(lm.obj.cn.logp)    # n.s. p=0.359

lm.obj.ru.logp <- lm(-dist_bylogp ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s,
                data=filter(d.obj, language=='Russian (RU)'))
summary(lm.obj.ru.logp)    # n.s. p=0.454

lm.obj.es.logp <- lm(-dist_bylogp ~ sent_pos.s + antec_id.s + sent_len.s + antec_surprisal.s,
                data=filter(d.obj, language=='Spanish (ES)'))
summary(lm.obj.es.logp)    # +; 0.0313 * 

lm.obj.tr.logp <- lm(-dist_bylogp ~ antec_id.s + sent_len.s + antec_surprisal.s,
                data=filter(d.obj, language=='Turkish (TR)'))
summary(lm.obj.tr.logp)    # n.s. p=0.0828 .
