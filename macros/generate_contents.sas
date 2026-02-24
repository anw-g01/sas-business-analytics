
*********************************************************************************************************
*                                                                             							*
*	Name:					generate_contents.sas														*
*                                                                             							*
*	Description:			Macro to run PROC CONTENTS for every dataset within a specified 			*
*							library and generate a PDF report of the contents.							*
*																										*											
*	Parameters:				Optional:																	*
*							- lib: name of library containing datasets (default = work)					*
*							- filename: name of the output PDF file (default = raw_metadata)			*
* 																										*
*	Creation Date:			Wed, 18 Feb 2026 															*
*                                                                             							*
*	Last Updated:			Mon, 23 Feb 2026															*
* 																										*
*	Created By:				Anwarat Gurung																*
*							Katalyze Data																*		
* 																										*
*********************************************************************************************************;

%macro generate_contents(lib=work, filename=raw_metadata);

	/* fetch and store all dataset names (+ count) from library as global macro variables */
	%store_dataset_names(lib=&lib.)

	/* generate a single PDF report */
	ods pdf file="&root.\reports\&filename..pdf"
			style=journal1a;
		ods noproctitle;	/* don't display default PROC CONTENTS titles */
			
			%if &num_ds. > 0 %then %do;
				/* run PROC CONTENTS for each dataset */
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