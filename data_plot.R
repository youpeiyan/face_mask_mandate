rm(list=ls())

library("tidyverse")
library("lubridate")
library("viridis")
library("readxl")
library("usmap")
library("ggplot2")
library("maps")
library("readxl")
library("maptools")
library("rgdal")
library("ggrepel")
mainpath<-"/Users/youpei/Downloads/Yale/COVID19_FM"
figpath <-"/Users/youpei/Downloads/Yale/COVID19_FM/figure"

####### Fig 1: Face Mask Mandate Time: Color-scaled dates

fm_data <- read_excel(paste0(figpath,"/data_plot.xlsx")) %>%
  mutate_at(vars(sipe_s,soe_cs,sip_cs,cks_cs,cnb_cs,fmm_cs, fmmb_s),as_date) %>%
  rename(fips=geoid)

states <- plot_usmap("states", color = "black", fill = NA)

## FMM
date_vec <- as_date(str_c("2020-",c("03-16","04-09","05-03","05-27","06-20","07-14","08-05")))

counties <- plot_usmap(data = fm_data %>% mutate(fmm_cs=as.numeric(fmm_cs)), values = "fmm_cs", color=NA, size=.01)  
ggplot() +
  counties$layers[[1]] +
  states$layers[[1]] +
  #scale_fill_date(low="blue",high="yellow",na.value="white") + 
  scale_fill_viridis(name="",breaks=as.numeric(date_vec),labels=format(date_vec,"%b-%d"),na.value="white") +
  theme_void() +
  coord_equal() +
  theme(legend.position = "right",
        legend.key.size = unit(1.2, "cm"),
        legend.key.width = unit(0.7,"cm"),
        legend.title = element_text(size = 18))  
ggsave(paste0(figpath,"/fmm.pdf"))

## FMM-Business
date_vec <- as_date(str_c("2020-",c("04-03","05-03","06-03","07-03","08-03")))

counties <- plot_usmap(data = fm_data %>% mutate(fmmb_s=as.numeric(fmmb_s)), values = "fmmb_s", color=NA, size=.01)  
ggplot() +
  counties$layers[[1]] +
  states$layers[[1]] +
  #scale_fill_date(low="blue",high="yellow",na.value="white") + 
  scale_fill_viridis(name="",breaks=as.numeric(date_vec),labels=format(date_vec,"%b-%d"),na.value="white") +
  theme_void() +
  coord_equal() +
  theme(legend.position = "right",
        legend.key.size = unit(1.2, "cm"),
        legend.key.width = unit(0.7,"cm"),
        legend.title = element_text(size = 18))  
ggsave(paste0(figpath,"/fmmb.pdf"))

####### Fig 2 (generated using Stata)

####### Fig 3: FMMB-state-pair Coefficient Plot
fmmb_coef <- read_excel(paste0(figpath,"/fmmb_coef.xlsx"))
final_data <- usmap_transform(fmmb_coef)
myColors <- c("firebrick1", "darkorchid4")

border <- plot_usmap(fill = "NA", alpha = 0.25,labels=TRUE) +
  ggrepel::geom_label_repel(data = final_data,
                            aes(x = lon.1, y = lat.1, label = ""),
                            size = 2, alpha = 0.8,
                            label.r = unit(0.2, "lines"), label.size = 0.2,
                            segment.color = "red", segment.size = 0.2,
                            seed = 1002) +
  geom_point(data = final_data,
             aes(x = lon.1, y = lat.1, size = size,color=factor(sign)), 
             show.legend = FALSE,
             alpha = 0.5) +
  scale_color_manual(values=myColors) +
  scale_size_continuous(range = c(1, 5)) 
border$layers[[2]]$aes_params$size <- 2

ggplot()+
  border$layers+
  theme_void() +
  coord_equal() +
  theme(legend.position = "none") 
ggsave(paste0(figpath,"/fmmb_border.pdf"))

####### Fig 4 (generated using Stata)

####### Fig S1: Number of days between FMM and the start of Stay-at-home
diff_data <- read_excel(paste0(figpath,"/diff_plot.xls")) %>%
  rename(fips=geoid)

states <- plot_usmap("states", color = "black", fill = NA)

## diff_fmm_sip
p_breaks <- c(8,28,48,68,88,108,128,148)
counties <- plot_usmap(data = diff_data %>% mutate(diff_fmm_sip=as.numeric(diff_fmm_sip)), values = "diff_fmm_sip", color=NA, size=.01)  

ggplot() +
  counties$layers[[1]] +
  states$layers[[1]] +
  scale_fill_viridis(name="",breaks=p_breaks,na.value="white") +
  theme_void() +
  coord_equal() +
  theme(legend.position = "right",
        legend.key.size = unit(1.2, "cm"),
        legend.key.width = unit(0.7,"cm"),
        legend.title = element_text(size = 18))
ggsave(paste0(figpath,"/diff_fmm_sip.pdf"))

## diff_fmmb_sip
p_breaks <- c(8,28,48,68,88,108,128,148)
counties <- plot_usmap(data = diff_data %>% mutate(diff_fmmb_sip=as.numeric(diff_fmmb_sip)), values = "diff_fmmb_sip", color=NA, size=.01)  

ggplot() +
  counties$layers[[1]] +
  states$layers[[1]] +
  scale_fill_viridis(name="",breaks=p_breaks,na.value="white") +
  theme_void() +
  coord_equal() +
  theme(legend.position = "right",
        legend.key.size = unit(1.2, "cm"),
        legend.key.width = unit(0.7,"cm"),
        legend.title = element_text(size = 18))  
ggsave(paste0(figpath,"/diff_fmmb_sip.pdf"))

####### Fig S2: Number of days between FMM and the end of Stay-at-home
## diff_fmm_sipe
p_breaks = c(-62,-31,0,31,62,93)
counties <- plot_usmap(data = diff_data %>% mutate(diff_fmm_sipe=as.numeric(diff_fmm_sipe)), values = "diff_fmm_sipe", color=NA, size=.01)  

ggplot()+
  counties$layers[[1]] +
  states$layers[[1]] +
  scale_fill_gradientn(colours=c("blue", "cyan","white","yellow","orange","red"), breaks= p_breaks, na.value="grey")+
  theme_void() +
  coord_equal() +
  labs(fill = "") +
  theme(legend.position = "right",
        legend.key.size = unit(1.2, "cm"),
        legend.key.width = unit(0.7,"cm"),
        legend.title = element_text(size = 18)) 
ggsave(paste0(figpath,"/diff_fmm_sipe.pdf"))

## diff_fmmb_sipe
p_breaks = c(-62,-31,0,31,62,91)
counties <- plot_usmap(data = diff_data %>% mutate(diff_fmmb_sipe=as.numeric(diff_fmmb_sipe)), values = "diff_fmmb_sipe", color=NA, size=.01)  

ggplot()+
  counties$layers[[1]] +
  states$layers[[1]] +
  scale_fill_gradientn(colours=c("blue", "cyan","white","yellow","orange","red"), breaks= p_breaks, na.value="grey")+
  theme_void() +
  coord_equal() +
  labs(fill = "") +
  theme(legend.position = "right",
        legend.key.size = unit(1.2, "cm"),
        legend.key.width = unit(0.7,"cm"),
        legend.title = element_text(size = 18)) 
ggsave(paste0(figpath,"/diff_fmmb_sipe.pdf"))

####### Fig S3: Counties that issued face mask mandates in a +/- 14 day window of the end of stay-at-home policies

## diff_fmm_sipe_14
counties <- plot_usmap(data = diff_data %>% mutate(diff_fmm_sipe_14=as.numeric(diff_fmm_sipe_14)), values = "diff_fmm_sipe_14", color=NA, size=.01)  
ggplot() +
  counties$layers[[1]] +
  states$layers[[1]] +
  scale_fill_continuous(name="",na.value="white") +
  theme_void() +
  coord_equal() +
  theme(legend.position = "none") 
ggsave(paste0(figpath,"/diff_fmm_sipe_14.pdf"))  

## diff_fmmb_sipe_14
counties <- plot_usmap(data = diff_data %>% mutate(diff_fmmb_sipe_14=as.numeric(diff_fmmb_sipe_14)), values = "diff_fmmb_sipe_14", color=NA, size=.01)  
ggplot() +
  counties$layers[[1]] +
  states$layers[[1]] +
  scale_fill_continuous(name="",na.value="white") +
  theme_void() +
  coord_equal() +
  theme(legend.position = "none") 
ggsave(paste0(figpath,"/diff_fmmb_sipe_14.pdf"))

####### Fig S4: snapshot of mask wearing frequancy
snap_data<- read_excel(paste0(figpath,"/snapshot.xlsx")) %>%
  rename(fips=geoid)

states <- plot_usmap("states", color = "black", fill = NA)
p_breaks <- c(0,1,2,3,4)
counties <- plot_usmap(data = snap_data %>% mutate(index=as.numeric(index)), values = "index", color=NA, size=.01)  

ggplot() +
  counties$layers[[1]] +
  states$layers[[1]] +
  scale_fill_viridis(name="",breaks=p_breaks,labels=c("never","rarely","somtimes","frequently","always"),na.value="white") +
  theme_void() +
  coord_equal() +
  theme(legend.position = "right",
        legend.key.size = unit(1.2, "cm"),
        legend.key.width = unit(0.7,"cm"),
        legend.title = element_text(size = 18))  
ggsave(paste0(figpath,"/snapshot.pdf"))


