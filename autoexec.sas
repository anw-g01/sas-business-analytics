
/* PATH TO PROJECT ROOT DIRECTORY */

%let root = C:\Users\anwarat.gurung\OneDrive - Katalyze Data\Documents\SAS\Anwarat - SAS Case Study;

/* STANDARD DATA LIBRARIES */

filename input 		"&root.\SAS\data\01_input";

libname raw			"&root.\SAS\data\02_raw";
libname staging 	"&root.\SAS\data\03_staging";
libname detail 		"&root.\SAS\data\04_detail";
libname marts 		"&root.\SAS\data\05_marts";
libname excep 	 	"&root.\SAS\data\06_exceptions";

/* AUTOCALL MACRO FOLDER PATH */

filename macros 	"&root.\SAS\macros";

/* SHARED SAS OBJECTS: FORMATS */

libname shared 		"&root.\SAS\shared";

/* GLOBAL SYSTEM OPTIONS */

options 
    mautosource sasautos=(macros, sasautos) 	/* search for macros within MACROS library 		*/
    fmtsearch=(shared work)                 	/* search for formats in SHARED library first 	*/
    msglevel=i                              	/* show informative log messages 				*/
    varinitchk=error                        	/* error if variables are uninitialised 		*/
    mergenoby=warn;                         	/* warning if merging without a BY statement 	*/