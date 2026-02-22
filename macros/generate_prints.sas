
%macro generate_prints(dslist=, obs=, filename=report, label=1, formats=);

	%local n i ds;

	%let n = %sysfunc(countw(&dslist.,%str( )));

	/* create a PDF report of data set observation prints */

	ods pdf file="&root.\reports\&filename..pdf"
			style=journal1a;

		%do i = 1 %to &n.;

			%let ds = %scan(&dslist., &i., %str( ));

			title1 "Sample of %upcase(&ds.) (obs=&obs.)";
			footnote1 height=10pt "Created on: %sysfunc(datetime(), fulldtfmt.)";

			proc print data=&ds.
					%if %length(&obs.) %then (obs=&obs.);		/* add an obs= option if provided */
					%if &label = 1 %then label;					/* add label option if label = 1 */
					obs="#";

				%if %length(&formats.) %then %do;
					format &formats.;
				%end;
			run;

			title1;
			footnote1;

		%end;

	ods pdf close;

%mend;