# This file includes the functions convert_into_png and convert_into_txt

# This function converts all pdf files into pngs using parallel computing
convert_into_png <- function(file_dir, cl) {
  pdflist <- list.files(path = file_dir, pattern = ".pdf", full.names = TRUE)
  if (length(pdflist) != 0) {
    pdflist <- paste0(getwd(), sub(".", "", pdflist))
  }
  parSapply(cl = cl, pdflist, function(x)
    pdf_convert(x, format = "png", pages = NULL, filenames = NULL, dpi = 250, verbose = TRUE))
}

# This function converts all png files into txt using parallel computing
# To do: add tif support
# To do: add another argument to tell tesseract,
#        whether it should try to preserve layout in document or not
convert_into_txt <- function(file_dir, tesseract_location, cl) {
  # obtains the list of png inside a folder and convert using parallel.
  wd <- getwd()
  pnglist <- list.files(path = wd, pattern = ".png", full.names = TRUE)
  foreach(png = pnglist) %dopar% {
    system(paste0(tesseract_location, " \"", png, "\" \"", gsub(".png", "", png), "\"", " -c preserve_interword_spaces=1"))
  }
  # generates the desired txt folder location
  txtlist <- list.files(path = wd, pattern = ".txt", full.names = TRUE)
  txtlist_rel <- list.files(path = wd, pattern = ".txt")
  txt_dir <- paste0(wd, sub(".", "", file_dir))
  txt_dir <- gsub("CaseFiles", "txt", txt_dir)
  txtlist_new <- paste0(paste0(txt_dir, "/"), txtlist_rel)
  if (!dir.exists(txt_dir)) {
    dir.create(txt_dir, recursive = TRUE)
  }
  for (i in 1:length(pnglist)) {
    file.copy(txtlist[i], txtlist_new[i])
  }
  # Confirmation of successful conversion
  if (length(txtlist) != 0) {
    print(paste("OCR successful, you can check txt file in:",
                txt_dir))
  }
  # Removes the temporary png and txt files
  file.remove(pnglist)
  file.remove(txtlist)
}