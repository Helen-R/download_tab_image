if (!"slackme" %in% ls()) source("../auxiliary/slackme.R")
source("function.R")

#!!!! then use converter from pdf to png
#!!!! xxxx.pdf --> xxxx/1.png
#!!!! # orgnaize png files
#!!!! # move *.png from "Tableau_pdf" to "Tableau_image_raw"
# print(out.dir)
# x <- list.files(out.dir, full.names = T, recursive = T, pattern = ".png")
# out.dir <- "Tableau_image_raw"
# if(!dir.exists(out.dir)) dir.create(out.dir, showWarnings = F)
# file.rename(x, file.path(out.dir, basename(gsub("/1.png", ".png", x))))

print(out.dir)
# convert pdf to png by imagemagick (to be specified the crop point, otherwise it's useless)
x <- list.files(out.dir, full.names = T, pattern = ".pdf")
# x <- x[1:20]
out.dir <- "Tableau_image_raw"
if(!dir.exists(out.dir)) dir.create(out.dir, showWarnings = F)
y <- file.path(out.dir, gsub(".pdf", ".png", basename(x)))

st.tm <- Sys.time()
for (i in 1:length(x)) {
  system(sprintf('magick -density 300 %s %s', x[i], y[i]))
}
slackme("converting done", st.tm)


# crop image
# crop raw png and save to "Tableau_image"
x <- list.files(out.dir, full.names = T)
out.dir <- "Tableau_image"
if(!dir.exists(out.dir)) dir.create(out.dir, showWarnings = F)
st.tm <- Sys.time()
for (i in 1:length(x)) {
  crop.image(x[i])
  print(sprintf("%s/%s: %s", i, length(x), basename(x)[i]))
  flush.console()
}
slackme("crop done", st.tm)
