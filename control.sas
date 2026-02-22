
/* SET GLOBAL OPTIONS FOR THIS PROGRAM */

options 
	nosource		/* supress SAS code from appearing in the log 	*/
	nosource2		/* suppress %include code in the log 			*/
	nonotes; 		/* hide all NOTE: messages 						*/


/* RUN ALL PROGRAMS SEQUENTIALLY */

%include "&root.\SAS\programs\01_import.sas";

%include "&root.\SAS\programs\02_prepare_households.sas";

%include "&root.\SAS\programs\03_prepare_bookings.sas";

%include "&root.\SAS\programs\04_prepare_shareholders.sas";

%include "&root.\SAS\programs\05_analytics_and_reporting.sas";


/* RESET GLOBAL OPTIONS TO DEFAULT */

options 
	source
	source2
	notes;