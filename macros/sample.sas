
*********************************************************************************************************
*                                                                             							*
*	Name:					sample.sas																	*
*                                                                             							*
*	Description:			Macro to generate a simple random sample from a specified SAS data 			*
*							set and print the selected observations. Supports optional column 			*
*							subsetting, row filtering, user defined formats, and labelled output.		*	
* 																										*
*	Parameters:				Required:																	*
*							- ds: name of the input dataset (with or without library)					*
*                                                                             							*
*							Optional:																	*
*							- obs: number of observations to sample (default = 12)						*
*							- keep: list of variables to keep in the sample (default = _ALL_)			*
*							- where: WHERE statement to filter observations (default = none)			*
*							- formats: list of variable formats to apply (default = none)				*
*							- label: toggle to display variable labels (default = 0)					*
*							- seed: random number seed for reproducibility (default = none)				*
*							- delete: toggle to delete the newly created sampled data set after 		*
*							printing in the work library (default = 1)									*
* 																										*
*	Creation Date:			Wed, 18 Feb 2026 															*
*                                                                             							*
*	Last Updated:			Mon, 23 Feb 2026															*
* 																										*
*	Created By:				Anwarat Gurung																*
*							Katalyze Data																*		
* 																										*
*********************************************************************************************************;

%macro sample(ds, obs=12, keep=_ALL_, where=, formats=, label=0, seed=, delete=1);

	/* check if supplied dataset exists */

	%if not %sysfunc(exist(&ds.)) %then %do;
		%put WARNING: Dataset "%upcase(&ds.)" does not exist.;
		%return;
	%end;

	/* grab the dataset name specifically (without library if provided) */

	%local name;    
	%if %index(&ds., %str(.)) %then			/* if a library name is provided */
		%let name = %scan(&ds., -1, .);		/* take the data set name without library name */
	%else 
		%let name = &ds.;					/* otherwise name is the dataset */

	/* grab a random sample from the dataset */

	proc surveyselect data=&ds.(
					      keep = &keep.
						  %if %length(&where.) %then 
						      where = &where.			/* add a WHERE statement if provided */
						  ;
					  )
					  out=&name._sample
					  method=srs 
					  sampsize=&obs. 					/* no of samples to pick randomly */
					  %if %length(&seed.) %then 
							seed=&seed. 				/* enforce a seed no. of provided */			  
					  ;
					  noprint;
					  
	run;

	/* display a printed report of the sample observations */

	title1 "Random Sample of %upcase(&ds.) (obs=&obs.)";
	footnote1 height=10pt "Created on: %sysfunc(datetime(), fulldtfmt.)";
		proc print data=&name._sample 
				%if &label. = 1 %then 
					label				/* add label option if label = 1 */
				;
				obs="#";			   	

			/* hardcode speciific formats for input datasets (for %sample_all macro) */

			%if %upcase(&name.) = HOUSEHOLDS %then %do;
				format 
					dob customer_startdate contact_date date9.;
			%end;
			%else %if %upcase(&name.) = BOOKINGS %then %do;
				format 
					booked_date departure_date date9.
					holiday_cost nlmnlgbp.2;
			%end;
			%else %if %upcase(&name.) = LOYALTY %then %do;
				format 
					invested_date date9.
					initial_value current_value nlmnlgbp.0;
			%end;

			/* format parameter option if specified */

			%if %length(&formats.) %then %do;
				format &formats.;
			%end;

		run;
	title1;
	footnote1;

	/* delete sample dataset outputs (toggle off by using delete = 0) */

	%if &delete. %then %do;
		proc datasets lib=work
					  noprint;
			delete &name._sample;
		quit;
	%end;
	
%mend;
