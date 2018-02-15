if (!"slackme" %in% ls()) source("../auxiliary/slackme.R")
if (!"mylib" %in% ls()) source("../auxiliary/mylib.R")
source("function.R")

# store.ids <- 1956
# views <- c("_/byShop", "__1/sheet0")
# image.names <- c("X1", "X2")

condi <- df$image_names %in% c("C2-1", "C2-2")
# condi <- df$image_names %in% df$image_names
# condi <- grep("C1", df$image_names)
# #xxx condi <- condi[-which(condi==which(df$image_names %in% "D1"))]

## image name to the output png file
image.names <- df$image_names[condi]
## which image of which workbook
views <- df$views[condi]

# output folder
out.dir <- "Tableau_pdf"
# out.dir <- "new"
if(!dir.exists(out.dir)) dir.create(out.dir, showWarnings = F)

# grab form Tableau server
svr <- readLines("../confidentials/download_tableau_image/svr.txt")
uid <- readLines("../confidentials/download_tableau_image/uid.txt")
pwd <- readLines("../confidentials/download_tableau_image/pwd.txt")
system(sprintf("tabcmd login -s %s -u %s -p %s", svr, uid, pwd))

st.tm <- Sys.time()
m <- 0
for (store.id in store.ids) {
  for (i in 1:length(views)) {
  view <- views[i]
  image.name <- image.names[i]
  if (image.name %in% c("C1-2", "C2-2")) {
    # get the file list to be copied (C1-1 or C2-1)
    previous.image.name <- gsub("-2", "-1", image.name)
    previous.fls <- list.files(out.dir, pattern = paste0(previous.image.name, ".pdf"), full.names = T)
    this.fls <- gsub("-1", "-2", previous.fls)
    tmp <- file.copy(from = previous.fls, to = this.fls)
  } else {
    download.image(view, store.id, image.name)
  }
  print(sprintf("%s in total %s", (i + m * length(views)), 
                length(store.ids) * length(views)))
  flush.console()
  Sys.sleep(1)}
  m <- m + 1
}
slackme("image download done", st.tm)

system("tabcmd logout")
