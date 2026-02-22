
/* ---------------------------- */
/* ---------- TASK 4 ---------- */
/* ---------------------------- */

proc format library=shared 
		  	cntlout=interest_coding(
				keep = start label
				rename = (
					start = code 
					label = description
				)
			);
	select $interestfmt;
run;

/* concatenate codes per activity into a single string per description */
/* PROC SQL did not work as expected -> code transformed into a DATA step */

proc sort data=interest_coding;
    by description;
run;

data interest_coding_grouped(drop = code);
    set interest_coding;
    by description;

	length letters $ 10;	/* variable to store space separated codes */
	retain letters;			/* DON'T reset letters on every iteration */

    if first.description then 
		letters = code;						/* get first code */
    else 
		letters = cats(letters, code);		/* concatenate all codes with a space */

    if last.description then output;
run;

/* view both interest mapping data sets */

proc print data=interest_coding				/* interest codes and descriptions */
		   obs="#";
run;

proc print data=interest_coding_grouped		/* gruoped interest codes for each description */
		   obs="#";
	var letters description;
run;

/* create macro variables for each interest description and codes */

proc sql noprint;

	/* each description -> desc1 - descN */
	select distinct 
		tranwrd(strip(lower(description)), " ", "_")
	into: desc1-
	from interest_coding;

	/* each description -> desc1 - descN */
	select distinct 
		letters
	into: codes1-
	from interest_coding_grouped
	order by description;			/* IMPORTANT: make sure ordering of codes1- is consistent with desc1- */

	/* count number of unique descriptions */
	select count(distinct description)
	into: num_interests
	from interest_coding;

quit;


%macro assign_interests(ds=);

	data &ds.;				/* set output data set */
		set &ds.;			/*set input data set */

		/* initialise each description as a variable to 0 */
		%do i = 1 %to &num_interests.;
			&&desc&i = 0;
		%end;

		/* loop through each interest letter code */
		do i = 1 to countw(interests, " ");				/* space separated interest codes */

			letter = scan(interests, i);				/* get the ith letter code */

			/* loop through each interest description */
			%do j = 1 %to &num_interests.;

				/* if letter is found within letters code, then toggle interest = 1 */
				if index("&&codes&j", strip(letter)) then 
					&&desc&j = 1;	
				;
			%end;
		end;
		
		drop i letter;
	run;

%mend;

%assign_interests(ds=detail.households_detail)
