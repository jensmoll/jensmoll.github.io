#!/bin/bash

cd "/Users/admin/Dropbox/R/Backend/WebsiteTables/"

#/usr/bin/git pull origin
Rscript CreateTables.R

/usr/bin/git checkout master
/usr/bin/git add .
/usr/bin/git commit -m 'Server Push'
/usr/bin/git push -u origin master