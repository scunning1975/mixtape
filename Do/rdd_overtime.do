* name: rdd_overtime.do
* section: regression discontinuity designs

clear
cd "/Users/scott_cunningham/Dropbox/Mixtape/Book"
import excel "/Users/scott_cunningham/Dropbox/Mixtape/Book/references to rdd.xlsx", sheet("Sheet1") firstrow clear

tsset total Year
label variable total "Number of Studies Mentioning RDD in a Year"
twoway (tsline total), ytitle(Number of Studies Mentioning RDD in a Year) ylabel(#6) ttitle(Year) title(The Explosion of Regression Discontinuity Designs)
