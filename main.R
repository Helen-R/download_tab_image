# source("download.tableau.image.R")
# source("crop.image.R")
# file.copy(from = "test/Tableau_image/", to = "Tableau_image/", overwrite = T)

# special case
if (!"mylib" %in% ls()) source("../auxiliary/mylib.R")
if (!"slackme" %in% ls()) source("../auxiliary/slackme.R")
source("function.R")

# download.image(view, store.id, image.name)
out.dir <- "test"
if(!dir.exists(out.dir)) dir.create(out.dir, showWarnings = F)
# grab form Tableau server
# grab form Tableau server
svr <- readLines("../confidentials/download_tableau_image/svr.txt")
uid <- readLines("../confidentials/download_tableau_image/uid.txt")
pwd <- readLines("../confidentials/download_tableau_image/pwd.txt")
system(sprintf("tabcmd login -s %s -u %s -p %s", svr, uid, pwd))


# download.image(view="MonthlyReport_1/WEBAPPMonthly_1", store.id=1451, image.name = "A5")
download.image(view="_6/sheet1", store.id = 2454, image.name = "C3")
a <- 962
download.image(view="_Yamanba/sheet0", store.id=a, image.name="D5-1")
x <- list.files(out.dir, full.names = T, pattern = a)
y <- file.path(out.dir, gsub(".pdf", ".png", basename(x)))
st.tm <- Sys.time()
for (i in 1:length(x)) {
  system(sprintf('magick -density 300 %s %s', x[i], y[i]))
}
slackme("converting done", st.tm)


# crop image
# crop raw png and save to "Tableau_image"
x <- list.files(out.dir, full.names = T, pattern = ".png")
x <- x[grep(a, x)]
out.dir <- file.path(out.dir, "Tableau_image")
if(!dir.exists(out.dir)) dir.create(out.dir, showWarnings = F)
st.tm <- Sys.time()
for (i in 1:length(x)) {
  crop.image(x[i])
  print(sprintf("%s/%s: %s", i, length(x), basename(x)[i]))
  flush.console()
}
slackme("crop done", st.tm)
