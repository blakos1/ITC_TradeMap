library(RSelenium)
library(wdman)
library(stringr)

# requirements:
#   java with PATH set up
#   firefox

#run once to run selenium server
#shell("java -jar selenium-server-standalone-3.9.1.jar")


#passwords and locations --------------------
pwtable = read.csv("password.csv", header = FALSE)
username = as.character(pwtable[1])
password = as.character(pwtable[2])

itc_login_site = "https://idserv.marketanalysis.intracen.org/Account/Login?ReturnUrl=%2Fconnect%2Fauthorize%2Fcallback%3Fclient_id%3DTradeMap%26scope%3Dopenid%2520email%2520profile%2520offline_access%2520ActivityLog%26redirect_uri%3Dhttps%253A%252F%252Fwww.trademap.org%252FLoginCallback.aspx%26state%3D8e91e1ec50d647ceb649bd87cf09c60c%26response_type%3Dcode%2520id_token%26nonce%3D0c095fc5b9404e1495028c3715432542%26response_mode%3Dform_post"
firefox_location = "C:/Users/U576750/AppData/Local/Mozilla Firefox/firefox.exe"


#script --------------------
rD = rsDriver(browser = "firefox",
              verbose = FALSE,
              extraCapabilities = list(
                acceptInsecureCerts = TRUE,
                acceptUntrustedCerts = TRUE,
                "moz:firefoxOptions" = list(
                  binary = firefox_location
                )
                )
              )
remDr = rD$client
#remDr$open()


#login to site --------------------
remDr$navigate(itc_login_site)

unbox = remDr$findElement(using = "id", "Username")
unbox$sendKeysToElement(list(username))

pwbox = remDr$findElement(using = "id", "Password")
pwbox$sendKeysToElement(list(password))

logxpath = "//button[contains(text(), 'Login')]"
logbox = remDr$findElement(using = "xpath", value = logxpath)
logbox$clickElement()

rm(unbox, pwbox, logxpath, logbox, username, password, pwtable)
Sys.sleep(3)

#----
#if acc is locked go to unlock page, else print that acc is unlocked
# Sys.sleep(5)
# lockimg = remDr$findElement(using = "id", "ctl00_MenuControl_Img_Login")
# 
# if(exists("lockimg")){
#   if(lockimg$isElementDisplayed()[[1]] == TRUE){
#     print("Account is locked")
#     remDr$navigate("https://www.trademap.org/stCaptcha.aspx")
#     # captchabox = remDr$findElement(using = "class", "div_captchaImg")
#   } else {
#     print("Lock image not found")
#   }
# } else {
#   print("Account is not locked")
# }


# captchaxpath = "/html/body/form/div[3]/table/tbody/tr/td/div/div[2]/div/img"
# captcha = remDr$findElement(using = "xpath", value = captchaxpath)
# captchasrc = captcha$getElementAttribute("src")[[1]]
# remDr$navigate(captchasrc)


# removedids = c("header", "footer", "marmenu", "ctl00_TitleContent", "ctl00_PageContent_Label1")
# 
# for (i in (1:length(removedids))){
#   remscript = paste("return document.getElementById(\'removedids[i]').remove();",
#                  sep = "")
#   remscript = str_replace(remscript, fixed("removedids[i]"), removedids[i])
#   remDr$executeScript(remscript)
# }
# 
# remDr$setWindowSize(300, 300)
# remDr$screenshot(display = TRUE)
# remDr$maxWindowSize()
# 
# captcha = readline(prompt = "Captcha content: ")
# 
# textbox = remDr$findElement(using = "id", "ctl00_PageContent_CaptchaAnswer")
# textbox$sendKeysToElement(list(captcha))
# 
# valxpath = '//*[@id="ctl00_PageContent_ButtonvalidateCaptcha"]'
# validatebtn = remDr$findElement(using = "xpath", valxpath)
# validatebtn$clickElement()
# 
# itc_homepage = "https://www.trademap.org/Index.aspx"
# remDr$navigate(itc_homepage)

# countrylist = c("Poland", "Germany")
# countrybox_id = "ctl00_PageContent_RadComboBox_Country_Input"
# countrybox = remDr$findElement(using = "id", countrybox_id)
# countrybox$clickElement()
# countrybox$sendKeysToElement(list(countrylist[1]))
# 
# countrybox_id2 = "ctl00_PageContent_RadComboBox_Country_c0"
# countrybox2 = remDr$findElement(using = "id", countrybox_id2)
# countrybox2$clickElement()

# m_bttn = "ctl00_PageContent_Button_TimeSeries_M"
# monthly_bttn = remDr$findElement(using = "id", m_bttn)
# monthly_bttn$clickElement()


# 
# remDr$mouseMoveToLocation(webElement = logg)
# remDr$click()

# validatebtn$click(buttonId = 1)
# valpos = validatebtn$getElementLocation()
# remDr$mouseMoveToLocation(valpos$x, valpos$y)
# remDr$refresh()
# remDr$getCurrentUrl()



#link generator ----

country_code = "203" # 616 Poland
partner_code = "" #203 Czech Republic
ntl_code2 = c("70109067")

exports = 2
imports = 1
export_import = c(exports, imports)

code_list = c("10","21","31","41","43",
              "45","47","51","53","55",
              "57","61","67","71","79",
              "91","99"
              )

# for (i in code_list){
#   ntl_code = paste0("701090", i)
# 
#   for (i in export_import){
#     
#     
#     
#     
#     
#   }
# }


link = paste0(
"https://www.trademap.org/Country_SelCountry_MQ_TS.aspx?nvpm=1%7c",
country_code,
"%7c%7c",
partner_code,
"%7c%7c",
ntl_code,
"%7c%7c%7c",
nchar(ntl_code),
"%7c1%7c1%7c",
exports,
"%7c2%7c3%7c2%7c2%7c1%7c1"
)

remDr$navigate("https://www.trademap.org/Country_SelCountry_MQ_TS.aspx?nvpm=1%7c%7c%7c%7c%7cTOTAL%7c%7c%7c2%7c1%7c1%7c2%7c2%7c3%7c2%7c1%7c1%7c1")
Sys.sleep(2)
remDr$navigate(link)

Sys.sleep(2)
saveexcel_id = "ctl00_PageContent_GridViewPanelControl_ImageButton_ExportExcel"
saveexcel = remDr$findElement(using = "id", saveexcel_id)
saveexcel$clickElement()






#shutdown --------------------
remDr$close()
rD$server$stop
rm(rD, remDr)
gc()

system("taskkill /im java.exe /f",
       intern = FALSE,
       ignore.stdout = FALSE)
