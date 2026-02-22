
*************************************************************************
*                                                           			*
*	Macro:			%GENERATE_CONTENTS									*	
*                                                           			*
* 	Description: 	Runs PROC CONTENTS for every data set in a 			*
*					specified SAS library. (Defaults to the WORK		*	
*					library if none provided). 							*
* 																		*
*   Parameters:															*
*  		LIB=		Library name to access data sets (default: WORK) 	*
* 																		*
*************************************************************************;

%macro generate_contents(lib=work, filename=raw_metadata);

	/* fetch and store all dataset names (+ count) from library as global macro variables */

	%store_datasets(lib=&lib.)

	/* generate a single PDF report */

	ods pdf file="&root.\reports\&filename..pdf"
			style=journal1a;
	ods noproctitle;    						/* don't display default titles */

		%if &num_ds. > 0 %then %do;
			%do i = 1 %to &num_ds.;
				
				title1 "Contents of %upcase(&&ds&i)";
				footnote1 height=10pt "Created on: %sysfunc(datetime(), fulldtfmt.)";

				proc contents data=&&ds&i
						      varnum;
				run;
				title1;
				footnote1;

			%end;
		%end;
		%else %put WARNING: zero data sets found in library "&lib.";

	ods proctitle;
	ods pdf close;

%mend;
