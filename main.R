# Script overview: This script is designed to convert pdf files into machine-readable txt files
# using tesseract, parallel computing and parallel libraries, coupled with the functions
# wrote in function.R. You have to manually set your casefiles' location using setwd(), 
# tesseract location, and number of threads your machine has.
# The default text output location will be outside your casefiles folders, named txt/

library(doParallel)
library(parallel)
library(pdftools)

# This is where you could add machine identification and specific CaseFiles locations.
if(Sys.info()["user"] == "Wayne") {
  numThreads <- 8
  tesseract_location <- file.path("C:/Program Files/Tesseract-OCR/tesseract.exe")
  source("function.R")
  tesseract_location <- paste0("\"", tesseract_location, "\"")
  setwd("records/CaseFiles/")
} else { # This is for server
  numThreads <- 3
  source("function.R")
  tesseract_location <- "tesseract"
  setwd("records/CaseFiles/")
}
cl <- makeCluster(numThreads)
registerDoParallel(cl)
clusterExport(cl, list("pdf_convert", "parSapply"))

# ----------------------
list_dir <- list.dirs(path = ".")

# Currently, we used a bigger for loop to go through all folders
# Within it, we will have two parallel loops to convert pdf into png
# and convert png into pdf
for (dir in list_dir) {
  convert_into_png(dir, cl)
  convert_into_txt(dir, tesseract_location, cl)
}

# To do: add another function that runs through the CaseFiles using different amount of threads
# up to numThreads, and generate a data frame that shows you the improvement for each increment
# in number of threads