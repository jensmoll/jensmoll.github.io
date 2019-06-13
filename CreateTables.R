getScriptPath <- function(){
  cmd.args <- commandArgs()
  m <- regexpr("(?<=^--file=).+", cmd.args, perl=TRUE)
  script.dir <- dirname(regmatches(cmd.args, m))
  if(length(script.dir) == 0) stop("can't determine script dir: please call the script with Rscript")
  if(length(script.dir) > 1) stop("can't determine script dir: more than one '--file' argument detected")
  return(script.dir)
}
dir <- getScriptPath()
setwd(dir)

library("git2r")
library("tableHTML")
source("GitFunctions.R")

# Git configuration
git2r::config(user.name = "riverfieldtt",
              user.email = "onlineaccounts@riverfieldtt.ch")


my.table = read.csv("../../../CSV/NAVextract.csv", header = FALSE, sep = ";", dec = ".")
colnames(my.table) = c("fund", "class", "currency", "NAV", "NAVdate", "prevNAV", "NAVvar", "OUTn")
my.table = my.table[with(my.table, order(fund, class)), ]

keep = matrix(1, nrow(my.table), 1)
for (i in 1:nrow(my.table)) {
  if (my.table[i, 2] == "BUS" && my.table[i, 3] == 'EUR') {
    keep[i] = 0
  } else if (my.table[i, 2] == "ACH" && my.table[i, 3] == 'EUR') {
    keep[i] = 0
  } else if (my.table[i, 2] == "BCH" && my.table[i, 3] == 'EUR') {
    keep[i] = 0
  }
}

my.table = my.table[as.logical(keep), ]
my.table[, c(4:8)] = round(my.table[, c(4:8)], 2)
my.table$NAVdate = format(as.Date(as.character(my.table$NAVdate), format = "%Y%m%d"), "%d/%m/%Y")
my.table[my.table == "BUS"] = "B"
my.table[my.table == "ACH"] = "A"
my.table[my.table == "BCH"] = "B"

my.table.equities = my.table[my.table$fund == "RIVERFIELD EQUITIES", ]
my.table.realassets = my.table[my.table$fund == "RIVERFIELD REAL ASSETS", ]
my.table.allrounder = my.table[my.table$fund == "RIVERFIELD ALLROUNDER", ]

names.export = c("Fund", "Class", "Currency", "NAV Per Share", "Prev. NAV Per Share",
                 "NAV Change in %", "Latest NAV Date")

# Reformating tables
complete.export = my.table[, c(1, 2, 3, 4, 6, 7, 5)]
colnames(complete.export) = names.export
equities.export = my.table.equities[, c(1, 2, 3, 4, 6, 7, 5)]
colnames(equities.export) = names.export
realassets.export = my.table.realassets[, c(1, 2, 3, 4, 6, 7, 5)]
colnames(realassets.export) = names.export
allrounder.export = my.table.allrounder[, c(1, 2, 3, 4, 6, 7, 5)]
colnames(allrounder.export) = names.export

widths = c(220, 50, 70, 90, 90, 100, 90)

t1 = tableHTML(complete.export, rownames = FALSE, widths = widths)
t1 = add_theme(t1, "scientific")
write_tableHTML(t1, file = 'complete.html')
t2 = tableHTML(equities.export, rownames = FALSE, widths = widths)
t2 = add_theme(t2, "scientific")
write_tableHTML(t2, file = 'equities.html')
t3 = tableHTML(realassets.export, rownames = FALSE, widths = widths)
t3 = add_theme(t3, "scientific")
write_tableHTML(t3, file = 'realassets.html')
t4 = tableHTML(allrounder.export, rownames = FALSE, widths = widths)
t4 = add_theme(t4, "scientific")
write_tableHTML(t4, file = 'allrounder.html')

# Commit to github!
gitadd()
gitcommit()
gitpush()

