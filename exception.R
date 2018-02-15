if (!"slackme" %in% ls()) source("../auxiliary/slackme.R")
source("function.R")
store.ids <- 2454

views <- c("_6/sheet1", "2454/sheet0")
image.names <- c("C3", "D5-2")
out.dir <- "test"
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

print(out.dir)
# convert pdf to png by imagemagick (to be specified the crop point, otherwise it's useless)
x <- list.files(out.dir, full.names = T, pattern = ".pdf")
# x <- x[1:20]
out.dir <- file.path(out.dir, "Tableau_image_raw")
if(!dir.exists(out.dir)) dir.create(out.dir, showWarnings = F)
y <- file.path(out.dir, gsub(".pdf", ".png", basename(x)))

st.tm <- Sys.time()
for (i in 1:length(x)) {
  system(sprintf('magick -density 300 %s %s', x[i], y[i]))
}
slackme("converting done", st.tm)
file.rename(x, file.path(o, x))

# crop image
# crop raw png and save to "Tableau_image"
x <- list.files(out.dir, full.names = T)
out.dir <- gsub("_raw", "", out.dir)
if(!dir.exists(out.dir)) dir.create(out.dir, showWarnings = F)
st.tm <- Sys.time()
for (i in 1:length(x)) {
  crop.image(x[i])
  print(sprintf("%s/%s: %s", i, length(x), basename(x)[i]))
  flush.console()
}
slackme("crop done", st.tm)
file.rename(y, file.path(o, y))
file.rename(gsub("_raw", "", x), file.path(o, gsub("_raw", "", x)))
if(length(list.files("test", recursive = T))==0) unlink("test", recursive = T)
