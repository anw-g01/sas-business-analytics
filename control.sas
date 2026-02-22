
/* SET GLOBAL OPTIONS FOR THIS PROGRAM */

options 
	nosource		/* supress SAS code from appearing in the log 	*/
	nosource2		/* suppress %include code in the log 			*/
	nonotes; 		/* hide all NOTE: messages 						*/


/* RUN ALL PROGRAMS SEQUENTIALLY */

%include "&root.\programs\01_import.sas";

%include "&root.\programs\02_clean.sas";

%include "&root.\programs\03.1_prepare_bookings.sas";

%include "&root.\programs\03.2_prepare_shareholders.sas";

%include "&root.\programs\04_analytics_and_reporting.sas";


/* RESET GLOBAL OPTIONS TO DEFAULT */

options 
	source
	source2
	notes;