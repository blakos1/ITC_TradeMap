library(RSelenium)
library(wdman)

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


#shutdown --------------------
remDr$close()
rD$server$stop
rm(rD, remDr)
gc()

system("taskkill /im java.exe /f",
       intern = FALSE,
       ignore.stdout = FALSE)
