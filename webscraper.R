{
  library(RSelenium)
  library(wdman)
  library(stringr)
  
  library(devtools)
  library(pkgbuild)
  stopifnot(find_rtools())
}

#passwords and locations --------------------

pwtable = read.csv("password.csv", header = FALSE)
username = as.character(pwtable[1])
password = as.character(pwtable[2])

download_path = paste0(getwd(), "/download_directory") %>% 
  normalizePath()

eCaps = list(chromeOptions = list(
  # args = c('--headless', '--disable-gpu', '--window-size=1280,800'),
  prefs = list("profile.default_content_settings.popups" = 0L,
               "download.prompt_for_download" = FALSE,
               "download.default_directory" = download_path)
))

rD = rsDriver(browser = c("chrome"),
              verbose = TRUE,
              chromever = "97.0.4692.71",
              port = 4447L
              ,extraCapabilities = eCaps
)
remDr = rD$client

# remDr$setTimeout(type = "implicit", milliseconds = 5000)
# remDr$setTimeout(type = "page load", milliseconds = 2000)

#login to site --------------------
remDr$navigate("https://google.com")
itc_login_site = "https://idserv.marketanalysis.intracen.org/Account/Login?ReturnUrl=%2Fconnect%2Fauthorize%2Fcallback%3Fclient_id%3DTradeMap%26scope%3Dopenid%2520email%2520profile%2520offline_access%2520ActivityLog%26redirect_uri%3Dhttps%253A%252F%252Fwww.trademap.org%252FLoginCallback.aspx%26state%3D8e91e1ec50d647ceb649bd87cf09c60c%26response_type%3Dcode%2520id_token%26nonce%3D0c095fc5b9404e1495028c3715432542%26response_mode%3Dform_post"
remDr$navigate(itc_login_site)

unbox = remDr$findElement(using = "id", "Username")
unbox$sendKeysToElement(list(username))

pwbox = remDr$findElement(using = "id", "Password")
pwbox$sendKeysToElement(list(password))

logxpath = "//button[contains(text(), 'Login')]"
logbox = remDr$findElement(using = "xpath", value = logxpath)
logbox$clickElement()


#link not loading properly workaround ----
link1 = "https://www.trademap.org/Country_SelCountry_MQ_TS.aspx?nvpm=1%7c%7c%7c%7c%7cTOTAL%7c%7c%7c2%7c1%7c1%7c2%7c2%7c3%7c2%7c1%7c%7c1"
link2 = "https://www.trademap.org/Country_SelCountry_MQ_TS.aspx?nvpm=1%7c203%7c%7c%7c%7c701090%7c%7c%7c6%7c1%7c1%7c2%7c2%7c3%7c2%7c2%7c1%7c1"
remDr$navigate(link1)
remDr$navigate(link2)

saveexcel_id = "ctl00_PageContent_GridViewPanelControl_ImageButton_ExportExcel"

code_list = c("10","21"#,"31","41","43"#,
              # "45","47","51","53","55",
              # "57","61","67","71","79",
              # "91","99"
)

for (i2 in code_list){
  ntl_code = paste0("701090", i2)
  ntl_path = paste0("//*/option[@value = '", ntl_code, "']")
  
  codebox = remDr$findElement(using = "xpath", ntl_path)
  codebox$clickElement()
  
  for (i1 in c(1:2)){
    export_path  = "//*/option[@value = 'E']"
    import_path  = "//*/option[@value = 'I']"
    im_ex_path = c(export_path, import_path)
    
    im_ex_box = remDr$findElement(using = "xpath", im_ex_path[i1])
    im_ex_box$clickElement()
    
    saveexcel = remDr$findElement(using = "id", saveexcel_id)
    saveexcel$clickElement()
  }
}

# workflow:
#   change country to e.g. czech republic
#   change product code to XX
#   change to export
#   download
#   change to import
#   download
#   change product code to YY
#   etc


#shutdown --------------------
{
  remDr$close()
  rD$server$stop
  rm(rD, remDr)
  gc()
  
  system("taskkill /im java.exe /f",
         intern = FALSE,
         ignore.stdout = FALSE)
}
