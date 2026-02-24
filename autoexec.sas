
/* PATH TO PROJECT ROOT DIRECTORY (CHANGE FOR YOUR SYSTEM) */

%let root = C:\Users\anwarat.gurung\OneDrive - Katalyze Data\Documents\SAS\Anwarat - SAS Case Study;

/* STANDARD DATA LIBRARIES */

filename input 		"&root.\data\01_input";

libname raw			"&root.\data\02_raw";
libname staging 	"&root.\data\03_staging";
libname detail 		"&root.\data\04_detail";
libname marts 		"&root.\data\05_marts";
libname excep 	 	"&root.\data\06_exceptions";

/* AUTOCALL MACRO FOLDER PATH */

filename macros 	"&root.\macros";

/* STORED FORMATS LIBRARY */

libname formats 	"&root.\formats";

/* GLOBAL SYSTEM OPTIONS */

options 
    mautosource sasautos=(macros, sasautos) 	/* search for macros within MACROS library 		*/
    fmtsearch=(formats work)                 	/* search for formats in SHARED library first 	*/
    msglevel=i                              	/* show informative log messages 				*/
    varinitchk=error                        	/* error if variables are uninitialised 		*/
    mergenoby=warn;                         	/* warning if merging without a BY statement 	*/