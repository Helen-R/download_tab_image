library(httr)
# grab form Tableau server
svr <- readLines("../confidentials/download_tableau_image/svr.txt")
uid <- readLines("../confidentials/download_tableau_image/uid.txt")
pwd <- readLines("../confidentials/download_tableau_image/pwd.txt")
url <- sprintf("%s/trusted", svr)
result <- GET(url, body = list(username = uid))#,
#                                server = svr))
result$all_headers$headers$`x-tsi-request-id`
result$headers[["x-tsi-request-id"]]

