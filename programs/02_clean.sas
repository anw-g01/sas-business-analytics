
*************************************************************************************************
*                                                                             					*
*	Name:					02_clean.sas														*
*                                                                             					*
*	Description:			Perform general cleaning and standardisation of input data 			*
*							sets to load into the STAGING library.								*
*                                                                             					*
*	Creation Date:			Sun, 22 Feb 2026 													*
*                                                                             					*
*	Last Updated:			Wed, 25 Feb 2026													*
* 																								*
*	Created By:				Anwarat Gurung														*
*							Katalyze Data														*		
* 																								*
************************************************************************************************;

/* clean RAW.HOUSEHOLDS and load into STAGING.HOUSEHOLDS */

data staging.households;
    set raw.households(rename = (title = old_title));

    /* standardise all title categories */
	if not missing(old_title) then 
		title = propcase(tranwrd(old_title, ".", ""));     /* remove full-stop and convert to title case */
	drop old_title;

    /* create an explicit ranking variable for genders */
	if lowcase(gender) = "f" then 
		gender_rank = 1;
	else if lowcase(gender) = "m" then 
		gender_rank = 2;
	else
		gender_rank = 3;	/* missing values ranked last rather than first */

    /* calculate the age of each customer */
	if not missing(dob) then
		age = floor(yrdif(dob, today(), "ACT/ACT"));	/* always round down to last completed year */
	else 
		call missing(age); 								/* set age variable to missing */

    /* create a location variable for each household (unique identifer) */
    length location $100;
    location = catx(" ", address1, postcode);	
    
    /* create a numerical id column for future sorting */
	id_num = input(customer_id, 10.);	
run;

/* print and view randomised samples of HOUSEHOLDS */

%sample(
    ds 		= staging.households, 
    obs		= 25,
    formats = dob customer_startdate contact_date date9.
)

/* inspect and check for any duplicate IDs across data sets */

%macro check_duplicates(ds, var);
	%let memname = %scan(&ds., -1, .);
	proc sql;
		create table dup_&memname. as (
			select &var.
			from &ds.
			group by &var.
			having count(*) > 1
		);
	quit;
%mend;

%check_duplicates(raw.households, customer_id)

%check_duplicates(raw.bookings, booking_id)

%check_duplicates(raw.loyalty, loyalty_id)