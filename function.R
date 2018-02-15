mylib("magick")
mylib("dtplyr")
suppressMessages(library("data.table"))

o <- "outcomes"
## get report name
df <- fread("report_list.csv", data.table=F)
df <- df[, c("views", "image_names", "x1", "y1", "x2", "y2")]
## irregular condition (need to be solved) 
## (because it takes two conditions, tabcmd doesn't recognicze it)
idx <- grep("A1", df$image_names)
## ruled out irregular
df <- df[-idx, ]

# shop id
store.ids <- read.table("shop_list.csv", header=T)$StoreId

crop.image <- function (filename) {
  image.name <- unlist(strsplit(gsub(".png", "", basename(filename)), "_"))[2]
  crop.point <- df[which(df$image_names %in% image.name), c("x1", "y1", "x2", "y2")]

  # set the position to be cropped
  width <- crop.point[3] - crop.point[1]
  height <- crop.point[4] - crop.point[2]
  x.start <- crop.point[1]
  y.start <- crop.point[2]

  # read in the image
  img <- image_read(filename)
  # crop the image
  img.crop <- image_crop(img, sprintf("%sx%s+%s+%s", width, height, x.start, y.start))
  # save the image
  ofn <- basename(filename) # output file name
  image_write(img.crop, path=file.path(out.dir, ofn), format="png")
  # return(ofn)
}


download.image <- function (view, store.id, image.name) {
  # output file name
  of <- paste0(store.id, "_", image.name, ".pdf")
  # of <- paste0(image.name, "_", store.id, ".png")
  print(of)
  flush.console()
  of <- file.path(out.dir, of)
  # set the address of report view by each store id
  if (view %in% "ECoupon/ECoupon_All_Dashboard") {
    view.address <- sprintf("%s?Shop%20sId=%s", view, store.id)
  } else if (view %in% "NAPL/Dashboard2") {
    view.address <- sprintf("%s?shopID=%s", view, store.id)
  } else {
    view.address <- sprintf("%s?StoreId=%s", view, store.id)
  }
  # set the command line and call it
  if (grepl("A2|A3|A4", image.name)) {
    image.size <- "--width 3200 --height 800"
  } else if (grepl("D1", image.name)) {
    image.size <- "--width 1200 --height 400"
  } else if (grepl("D4", image.name)) {
    image.size <- "--width 1100 --height 550"
  } else {
    image.size <- "--width 1000 --height 500"
  }
  cmd.line <- sprintf('tabcmd export "%s" --pdf --pagesize unspecified %s --filename %s', 
                       view.address, image.size, of)

  system(cmd.line)
}
