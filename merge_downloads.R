library(XML)
library(stringr)
library(dplyr)
library(xlsx)
library(tidyr)
library(purrr)

# download_directory
input_path = paste0(getwd(), "/download_directory/input")
output_path = paste0(getwd(), "/download_directory/output")

# function ----
join_files = function(directory, country, import=c("import","export")){
  filenames = list.files(directory, full.names = TRUE) %>%
    grep(pattern = "\\.xml", value = TRUE) %>%
    grep(pattern = paste0("*", country, "*"), value = TRUE) %>%
    grep(pattern = paste0("*", import, "*"), value = TRUE)

  output_list = list()
  for (i in filenames){
    x = readLines(i, encoding = "UTF-8")
    
    x = x %>% 
      str_remove_all(pattern = '<td>Kilograms</td>') %>% 
      str_remove_all(pattern = '<td></td>') %>%  
      str_remove_all(pattern = '<td>Units</td>') %>%  
      str_remove_all(pattern = '<th scope="col">Unit</th>') %>% 
      str_replace(pattern = '<td align="center" colspan="2">',
                  replacement = '<td align="center" colspan="1">') %>% 
      str_replace_all(pattern = "Côte d'Ivoire", replacement = "Ivory Coast") %>% 
      str_replace_all(pattern = "Brunei Darussalam", replacement = "Brunei") %>% 
      str_replace_all(pattern = "Libya, State of", replacement = "Libya") %>% 
      str_replace_all(pattern = "Bolivia, Plurinational State of", replacement = "Bolivia") %>% 
      str_replace_all(pattern = "Syrian Arab Republic", replacement = "Syria") %>% 
      str_replace_all(pattern = "Palestine, State of", replacement = "Palestine") %>% 
      str_replace_all(pattern = "Brunei Darussalam", replacement = "Brunei") %>% 
      str_replace_all(pattern = "Venezuela, Bolivarian Republic of", replacement = "Venezuela") %>% 
      str_replace_all(pattern = "Congo, Democratic Republic of the", replacement = "Democratic Republic of the Congo") %>% 
      str_replace_all(pattern = "Viet Nam", replacement = "Vietnam") %>% 
      str_replace_all(pattern = "Tanzania, United Republic of", replacement = "Tanzania") %>% 
      str_replace_all(pattern = "Macedonia, North", replacement = "North Macedonia") %>% 
      str_replace_all(pattern = "Taipei, Chinese", replacement = "Taiwan") %>% 
      str_replace_all(pattern = "Russian Federation", replacement = "Russia") %>% 
      str_replace_all(pattern = "Hong Kong, China", replacement = "Hong Kong") %>% 
      str_replace_all(pattern = "Korea, Republic of", replacement = "South Korea") %>%  
      str_replace_all(pattern = "Moldova, Republic of", replacement = "Moldova") %>% 
      str_replace_all(pattern = "Iran, Islamic Republic of", replacement = "Iran") %>% 
      str_replace_all(pattern = "Macao, China", replacement = "Macao")

    x = readHTMLTable(x)

    product_code = x[[1]] %>% 
      str_replace_all(pattern = "[^0-9]", replacement = "") %>% 
      as.integer()
    # colnames(product_code) = "Product"
    
    # description = as.character(x[[1]])
    # colnames(description) = "Description"
    
    product_table = as.data.frame(x[[7]])
    colnames(product_table)[1] = "Partner"
    
    merged_df = data.frame("Product" = product_code,
                           # "Description" = description,
                           "Trade_Flow" = str_to_sentence(import),
                           "Country" = country) %>% 
      # merge(product_code, description) %>% 
      merge(product_table) %>% 
      na.omit()
    
    longer_df = pivot_longer(merged_df, cols = c(5:ncol(merged_df)),
                             names_to = "Date",
                             values_to = "Value")
    
    longer_df$Value = round(as.numeric(longer_df$Value) / 1000, 1) 
    longer_df = longer_df[!(longer_df$Partner == "World"), ]
    
    output_list[[i]] = longer_df
  }

  final_df = bind_rows(output_list)
  return(final_df)
}

# manual convert xls to xml/html ----
xls_df = file.info(list.files(input_path,
                              full.names = TRUE,
                              pattern = "\\.xls")
)

for (i in rownames(xls_df)){
  new_filename = i %>%
    str_replace("\\.xls", "\\.xml")
  file.rename(i, new_filename)
}

# create output file
country_list = as.list(read.csv("input/country_list.csv", header = FALSE))

for (i in country_list){
  outputs = list()
  outputs[[1]] = join_files(input_path, i, "export")
  outputs[[2]] = join_files(input_path, i, "import")
  
  merged = merge(outputs[[1]], outputs[[2]],
                 by = c("Product", "Country", "Partner", "Date"),
                 all = TRUE)
  merged$Trade_Flow.x = "Export"
  merged$Trade_Flow.y = "Import"
  merged$Trade_Flow = "Balance"
  
  merged = mutate_all(merged, ~replace(., is.na(.), 0))
  merged$Value = merged$Value.x - merged$Value.y
  outputs[[3]] = subset(merged, select = -c(Trade_Flow.x, Value.x, Trade_Flow.y, Value.y))
  
  outputs = bind_rows(outputs[[1]], outputs[[2]]) %>% 
    bind_rows(outputs[[3]]) 
  
  outputs %>% 
    write.xlsx(file = paste0(output_path,"/", i, "_merged2.xlsx"),
               sheetName = paste0(i, "_trade"))
  rm(merged, outputs)
}

# joined = join_files(input_path, "Italy", "export")