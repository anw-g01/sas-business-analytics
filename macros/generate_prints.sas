
*********************************************************************************************************
*                                                                             							*
*	Name:					generate_prints.sas															*
*                                                                             							*
*	Description:			Macro to generate a PDF report containing printed samples of multiple		*
*							data sets supplied as a space separated list.								*
* 																										*
*	Parameters:				Required:																	*
*							- dslist: space separated list of data set names							*
*                                                                             							*
*							Optional:																	*
*							- obs: number of observations to sample from each dataset (default = 30)	*
* 							- filename: name of the output PDF file (default = report)					*
* 							- label: toggle to display variable labels (default = 1)					*
* 							- formats: space separated list of format names to apply (default = none) 	*
* 																										*
*	Creation Date:			Fri, 20 Feb 2026 															*
*                                                                             							*
*	Last Updated:			Mon, 24 Feb 2026															*
* 																										*
*	Created By:				Anwarat Gurung																*
*							Katalyze Data																*		
* 																										*
*********************************************************************************************************;

%macro generate_prints(dslist=, obs=30, filename=report, label=1, formats=);

	/* check if dslist parameter is not empty */
	%if %length(&dslist.) = 0 %then %do;
		%put ERROR: No list of space-separated data sets provided in "dslist" parameter.;
		%return;
	%end;

	%local n i ds;									/* optional: localise all used macro variables */
	%let n = %sysfunc(countw(&dslist., %str( )));	/* count the number of datasets in the input list (space separated) */

	/* create a PDF report of data set observation prints */
	ods pdf file="&root.\reports\&filename..pdf"
			style=journal1a;

		/* generate a printed report for each dataset in the input list */
		%do i = 1 %to &n.;

			%let ds = %scan(&dslist., &i., %str( ));	/* grab data set name from the input list */

			/* print the data set with specified options */
			title1 "Sample of %upcase(&ds.) (obs=&obs.)";
			footnote1 height=10pt "Created on: %sysfunc(datetime(), fulldtfmt.)";
				proc print data=&ds.
						%if %length(&obs.) %then (obs=&obs.);		/* obs= option if provided */
						%if &label = 1 %then label;					/* label option if label = 1 */
						obs="#";

					%if %length(&formats.) %then %do;
						format &formats.;							/* formats option if provided */
					%end;
				run;
			title1;
			footnote1;

		%end;

	ods pdf close;

%mend;