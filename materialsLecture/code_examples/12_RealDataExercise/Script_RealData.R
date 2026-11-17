#===============================================================================#
#===============================================================================#
# #
# Titel #
# #
# Autor: Aurélien Sallin
# Datum: XX.XX.XX #
# #
#===============================================================================#
#===============================================================================#

# Funktionen
ORACLE <- TRUE
source("//swicanet.swica.ch@SSL/DavWWWRoot/Organization/spezialthemen/DocumentsGeneral/_hilfsfunktionen/R/000_Source_ASA.R")
path = ''
path_output = ''




# Import tables from DWH --------------------------------------------------

# Table 1: save as json
query <- paste0(
  "SELECT JAHR
    , KANTON_PAT
    , AA_TYPE
    , v2.B003_GESCHLECHT_KBEZ
    , CASE
        WHEN JAHR_STA - EXTRACT(YEAR FROM v2.B003_GEBURTSTAG) <= 18 THEN '0-18'
        WHEN JAHR_STA - EXTRACT(YEAR FROM v2.B003_GEBURTSTAG) <= 25 THEN '19-25'
        WHEN JAHR_STA - EXTRACT(YEAR FROM v2.B003_GEBURTSTAG) <= 30 THEN '26-30'
        WHEN JAHR_STA - EXTRACT(YEAR FROM v2.B003_GEBURTSTAG) <= 35 THEN '31-35'
        WHEN JAHR_STA - EXTRACT(YEAR FROM v2.B003_GEBURTSTAG) <= 40 THEN '36-40'
        WHEN JAHR_STA - EXTRACT(YEAR FROM v2.B003_GEBURTSTAG) <= 45 THEN '41-45'
        WHEN JAHR_STA - EXTRACT(YEAR FROM v2.B003_GEBURTSTAG) <= 50 THEN '46-50'
        WHEN JAHR_STA - EXTRACT(YEAR FROM v2.B003_GEBURTSTAG) <= 55 THEN '51-55'
        WHEN JAHR_STA - EXTRACT(YEAR FROM v2.B003_GEBURTSTAG) <= 60 THEN '56-60'
        WHEN JAHR_STA - EXTRACT(YEAR FROM v2.B003_GEBURTSTAG) <= 65 THEN '61-65'
        WHEN JAHR_STA - EXTRACT(YEAR FROM v2.B003_GEBURTSTAG) <= 70 THEN '66-70'
        WHEN JAHR_STA - EXTRACT(YEAR FROM v2.B003_GEBURTSTAG) <= 75 THEN '71-75'
        WHEN JAHR_STA - EXTRACT(YEAR FROM v2.B003_GEBURTSTAG) <= 80 THEN '76-80'
        WHEN JAHR_STA - EXTRACT(YEAR FROM v2.B003_GEBURTSTAG) <= 85 THEN '81-85'
        WHEN JAHR_STA - EXTRACT(YEAR FROM v2.B003_GEBURTSTAG) <= 90 THEN '86-90'
        ELSE '91-' END AS age_group
    , sum(abs(DWH_PLE )) as PLE_Kosten
    , sum(abs(ANZAHL_KONS)) as ANZAHL_KONS
    FROM T_ASA_STAMMTEST_KONS_V0
    left join t_asa_stammtest_v0 v2
        using (BO_PAR_BOID)
    GROUP BY JAHR, AA_TYPE, KANTON_PAT, v2.B003_GESCHLECHT_KBEZ,
    CASE
        WHEN JAHR_STA - EXTRACT(YEAR FROM v2.B003_GEBURTSTAG) <= 18 THEN '0-18'
        WHEN JAHR_STA - EXTRACT(YEAR FROM v2.B003_GEBURTSTAG) <= 25 THEN '19-25'
        WHEN JAHR_STA - EXTRACT(YEAR FROM v2.B003_GEBURTSTAG) <= 30 THEN '26-30'
        WHEN JAHR_STA - EXTRACT(YEAR FROM v2.B003_GEBURTSTAG) <= 35 THEN '31-35'
        WHEN JAHR_STA - EXTRACT(YEAR FROM v2.B003_GEBURTSTAG) <= 40 THEN '36-40'
        WHEN JAHR_STA - EXTRACT(YEAR FROM v2.B003_GEBURTSTAG) <= 45 THEN '41-45'
        WHEN JAHR_STA - EXTRACT(YEAR FROM v2.B003_GEBURTSTAG) <= 50 THEN '46-50'
        WHEN JAHR_STA - EXTRACT(YEAR FROM v2.B003_GEBURTSTAG) <= 55 THEN '51-55'
        WHEN JAHR_STA - EXTRACT(YEAR FROM v2.B003_GEBURTSTAG) <= 60 THEN '56-60'
        WHEN JAHR_STA - EXTRACT(YEAR FROM v2.B003_GEBURTSTAG) <= 65 THEN '61-65'
        WHEN JAHR_STA - EXTRACT(YEAR FROM v2.B003_GEBURTSTAG) <= 70 THEN '66-70'
        WHEN JAHR_STA - EXTRACT(YEAR FROM v2.B003_GEBURTSTAG) <= 75 THEN '71-75'
        WHEN JAHR_STA - EXTRACT(YEAR FROM v2.B003_GEBURTSTAG) <= 80 THEN '76-80'
        WHEN JAHR_STA - EXTRACT(YEAR FROM v2.B003_GEBURTSTAG) <= 85 THEN '81-85'
        WHEN JAHR_STA - EXTRACT(YEAR FROM v2.B003_GEBURTSTAG) <= 90 THEN '86-90'
        ELSE '91-' END  
    ORDER BY KANTON_PAT, JAHR, AA_TYPE;")

data <- data.table(dbGetQuery(con, query, encoding = "latin1"))
data <- data %>% 
    mutate(B003_ALTERSGRUPPE = AGE_GROUP)  %>% 
    select(-AGE_GROUP)  %>% 
    select(-B003_ALTERSG)

library(jsonlite)
json_data <- toJSON(data)
write(json_data, file = "H:/Blog_KongressBerlin/medi_data.json")


# Table 2
query <- paste0("SELECT * FROM t_asa_stammtest_v0") 
dataSTAMM     <- data.table(dbGetQuery(con, query, encoding = "latin1"))

dataSTAMM1 <- dataSTAMM |> 
  mutate(age = JAHR_STA - year(B003_GEBURTSTAG),
    age_group = create_agegroups(age)) |> 
  group_by(JAHR_STA, KANTON, B003_GESCHLECHT_KBEZ, age_group, JAHRESFRANCHISE_E, JAHRESFRANCHISE_K) |> 
  summarize(ANZAHL_VERS_MONATE = sum(ANZAHL_VERS_MONATE) ,
            ANZAHL_VERS = n_distinct(BO_PAR_BOID) )  %>% 
  ungroup()  

# Add random variation
dataSTAMM1 <- dataSTAMM1 |>
  mutate(ANZAHL_VERS_MONATE = ANZAHL_VERS_MONATE + runif(nrow(dataSTAMM1), -36, 36)) |>
  mutate(ANZAHL_VERS = ANZAHL_VERS + runif(nrow(dataSTAMM1), -3, 3))

dataSTAMM1 <- dataSTAMM1  |> 
  mutate(ANZAHL_VERS = ifelse(ANZAHL_VERS < 40, NA, ANZAHL_VERS))  %>% 
  mutate(age_group = SWICAtoolsVFO::aggregate_agegroups(age_group))

write_tsv(dataSTAMM1, file = "H:/Blog_KongressBerlin/stamm_data.csv")



dataSTAMM  %>% 
  mutate(age = JAHR_STA - year(B003_GEBURTSTAG))  %>% 
  mutate(JAHRESFRANCHISE = ifelse(age <18, JAHRESFRANCHISE_K, JAHRESFRANCHISE_E))  %>% 
  filter(age >18)  %>%
  group_by(JAHRESFRANCHISE, JAHR_STA)  %>% 
  summarize(meanAge = mean(age))  %>% 
  ggplot(aes(x = as.factor(JAHRESFRANCHISE), y = meanAge, 
             color = as.factor(JAHR_STA),
             group = as.factor(JAHR_STA))) +
  geom_point() +
  geom_line() +
  facet_wrap(JAHR_STA ~. ) +
  theme_classic()



#===============================================================================#
#============================= END =============================================#
#===============================================================================#
