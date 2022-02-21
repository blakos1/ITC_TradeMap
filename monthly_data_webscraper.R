#packages --------------------
{
  library(RSelenium)
  library(wdman)
  library(stringr)
  library(tools)
  
  library(devtools)
  library(pkgbuild)
  stopifnot(find_rtools())


#password and download location --------------------
pwtable = read.csv("input/password.csv", header = FALSE)
username = as.character(pwtable[1])
password = as.character(pwtable[2])

if(!dir.exists("montly_data")){
  dir.create("montly_data")
}

download_path = paste0(getwd(), "/montly_data") %>% 
  normalizePath()


#codes and countries --------------------
code_list = read.csv("input/code_list.csv", header = FALSE)
code_list = as.vector(t(code_list))

country_list = read.csv("input/country_list.csv", header = FALSE)
country_list = as.vector(t(country_list))


#start browser --------------------
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

#locked account check --------------------
#if acc is locked go to unlock page, else print that acc is unlocked
lockimg = remDr$findElement(using = "id", "ctl00_MenuControl_Img_Login")

if(exists("lockimg")){
  if(lockimg$isElementDisplayed()[[1]] == TRUE){
    print("Account is locked")
    lockimg$clickElement()
    # remDr$navigate("https://www.trademap.org/stCaptcha.aspx")
    # captchabox = remDr$findElement(using = "class", "div_captchaImg")
  } else {
    print("Lock image not found")
  }
} else {
  print("Account is not locked")
}


locktxt = remDr$findElement(using = "id", "ctl00_PageContent_CaptchaAnswer")

if(exists("locktxt")){
  if(locktxt$isElementDisplayed()[[1]] == TRUE){
    remDr$screenshot(display = TRUE)
    validatebttn = remDr$findElement(using = "id", "ctl00_PageContent_ButtonvalidateCaptcha")
    
    captcha_text = readline("Solved captcha:")
    
    locktxt$sendKeysToElement(list(captcha_text))
    validatebttn$clickElement()
  }
}
}

#fil out homepage --------------------
# link1 = "https://www.trademap.org/Country_SelCountry_MQ_TS.aspx?nvpm=1%7c%7c%7c%7c%7cTOTAL%7c%7c%7c2%7c1%7c1%7c2%7c2%7c3%7c2%7c1%7c%7c1"
# link2 = "https://www.trademap.org/Country_SelCountry_MQ_TS.aspx?nvpm=1%7c203%7c%7c%7c%7c701090%7c%7c%7c6%7c1%7c1%7c2%7c2%7c3%7c2%7c2%7c1%7c1"
# remDr$navigate(link1)
# remDr$navigate(link2)
{
homepage_link = "https://www.trademap.org/Index.aspx"
remDr$navigate(homepage_link)

fill_homepage = function(){
  placeholder = "ctl00_PageContent_RadComboBox_Product_Input"
  c_path = remDr$findElement(using = "id", placeholder)
  c_path$sendKeysToElement(list("701090"))
  c_path$clearElement()
  c_path$sendKeysToElement(list("701090"))
  Sys.sleep(2)
  c_path$sendKeysToElement(list(key = "down_arrow"))
  c_path$sendKeysToElement(list(key = "enter"))
  
  placeholder = "ctl00_PageContent_Button_TimeSeries_M"
  c_path = remDr$findElement(using = "id", placeholder)
  c_path$clickElement()
  
  Sys.sleep(1)
  q_path = paste0("//*/option[@value = 'Q']")
  q_box = remDr$findElement(using = "xpath", q_path)
  q_box$clickElement()
}

fill_homepage()

check_url = function(){
  current_url = remDr$getCurrentUrl()[[1]]
  if (current_url == homepage_link){
    fill_homepage()
  }
}


#download data --------------------
saveexcel_id = "ctl00_PageContent_GridViewPanelControl_ImageButton_ExportExcel"

for (i3 in country_list){
  check_url()
  
  country_path = paste0("//*/option[@title = '", i3, "']")
  country_box = remDr$findElement(using = "xpath", country_path)
  country_box$clickElement()

  # timeperiod_path = paste0("//*/option[@value = '20']")
  # timeperiod_box = remDr$findElement(using = "xpath", timeperiod_path)
  # timeperiod_box$clickElement()
  
  for (i2 in code_list){
    check_url()
    
    ntl_code = paste0("701090", i2)
    ntl_path = paste0("//*/option[@value = '", ntl_code, "']")
    
    code_box = remDr$findElement(using = "xpath", ntl_path)
    code_box$clickElement()
    
    for (i1 in c(1:2)){
      check_url()
      
      export_path  = "//*/option[@value = 'E']"
      import_path  = "//*/option[@value = 'I']"
      im_ex_path = c(export_path, import_path)
      
      im_ex_box = remDr$findElement(using = "xpath", im_ex_path[i1])
      im_ex_box$clickElement()
      
      saveexcel = remDr$findElement(using = "id", saveexcel_id)
      saveexcel$clickElement()
    }
  }
}
}

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


#rename data --------------------
{
filenames_df = file.info(list.files(download_path,
                                    full.names = TRUE,
                                    pattern = "*Trade_Map_-*")
)

for (i in rownames(filenames_df)){
  new_filename = i %>%
    str_remove("Trade_Map_-.*product_") %>% 
    str_remove("_by")
  
  file.rename(i, new_filename)
}
}
