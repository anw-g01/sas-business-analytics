
*****************************************************************************************************
*                                                                             						*
*	Name:					03.1_prepare_households.sas												*
*                                                                             						*
*	Description:			Prepare the HOUSEHOLDS customer data set by constructing greeting 		*
*							messages, identifying primary householders, and deriving holiday 		*
*							interest indicators. Output contact-specific datasets and generate		*
*							a sample PDF report.													*
*                                                                             						*
*	Creation Date:			Fri, 30 Jan 2026 														*
*                                                                             						*
*	Last Updated:			Mon, 23 Feb 2026														*
* 																									*
*	Created By:				Anwarat Gurung															*
*							Katalyze Data															*		
* 																									*
*****************************************************************************************************;

/* --------------------------------------------------------------------------- */
/* ---------- TASK: construct a customer greeting message variable  ---------- */
/* --------------------------------------------------------------------------- */

data households_detail;
	set staging.households;		/* read in the cleaned HOUSEHOLDS data set from the STAGING library */

	length greeting $40;
	label greeting = "Customer Greeting";

	/* infer GENDER if a title is available */
	if missing(gender) and not missing(title) then do;
		if title in ("Mrs", "Miss", "Ms") then 
			gender = "F";
		else if title in ("Mr", "Sir") then
			gender = "M";
		/* gender neutral title "Dr" will be ignored */
	end;

	/* infer TITLE if a gender is available */
	if missing(title) and not missing(gender) then do;
		if gender = "F" then
			title = "Ms";
		else if gender = "M" then
			title = "Mr";
	end;

	/* construct the greeting message */
	if (missing(gender) and missing(forename)) or missing(family_name) then
		greeting = "Dear Customer";
	else
		greeting = catx(" ", "Dear", title, substr(forename, 1, 1), family_name);
run;

/* ------------------------------------------------------------------------------------ */
/* ---------- TASK: identify primary householders (based on specified rules) ---------- */
/* ------------------------------------------------------------------------------------ */

proc sort data=households_detail;
	by 
		location			/* sort by location variable (unique household identifier) 	*/
		gender_rank 		/* prioritise females (missing genders last) 				*/
		descending age;		/* prioritise oldest of each gender 						*/
run;

data households_detail;
	set households_detail;	
	
	/* group by the same sorting variables (order hierarchy) */
	by location gender_rank descending age;	   	
	
	/* assign household IDs and primary householder flags based on the first record of each group */
	if first.location then do;
		household_id + 1;			/* increment HOUSEHOLD_ID for each new location (i.e. household) */
		primary_householder = 1;	/* primary householder is sorted as first */
	end;
	else 
		primary_householder = 0;	/* assign 0 to all other customers within the same location/household */
run;

/* ----------------------------------------------------------------------- */
/* ---------- TASK: derive a variable for each holiday interest ---------- */
/* ----------------------------------------------------------------------- */

/* create a holiday interests coding data set (used to create macro variables) */

data interest_coding;
    infile datalines dsd dlm=",";
    input 
        codes : $3. 
        description : $20.;
    datalines;
AKL,Mountaineering 
B,Water Sports 
CX,Sightseeing 
D,Cycling 
E,Climbing 
FW,Dancing 
HG,Hiking 
J,Skiing 
M,Snowboarding 
N,White Water Rafting 
PQR,Scuba Diving 
S,Yoga 
TU,Mountain Biking 
VYZ,Trail Walking
;
run;

/* generate global macro variables for dynamic use in a macro */

proc sql noprint;

    /* store interest codes as macro variables */
    select codes 
    into: codes1-
    from interest_coding;

    /* store interest descriptions as macro variables */
    select tranwrd(lower(strip(description)), " ", "_")
    into: desc1-
    from interest_coding;

    /* store count of interests as a macro variable */
    select count(*)
    into: num_interests
    from interest_coding;

	/* OPTIONAL: store non-underscored descriptions for labelling */
    select description
    into: interest_label1-
    from interest_coding;

	/* OPTIONAL: create a space separated macro variable list of all interests */
	select tranwrd(lower(strip(description)), " ", "_")
	into: all_interests separated by " "
	from interest_coding;

quit;

/* create a boolean interest flag variable for ALL holiday interests */

%macro assign_interests;

	data households_detail;				/* hardcoded data set name (specific macro relevant for data set only) */
		set detail.households_detail;	/* read in the HOUSEHOLDS_DETAIL data set from the DETAIL library */		

		/* initialise each description as a variable to 0 */
		%do i = 1 %to &num_interests.;
			&&desc&i = 0;
			label &&desc&i = "&&interest_label&i"; 		/* optional label */
		%end;

		/* loop through each interest letter code */
		do i = 1 to countw(interests, " ");				/* space separated interest codes */

			letter = scan(interests, i);				/* get the ith letter code */

			/* loop through each interest description */
			%do j = 1 %to &num_interests.;

				/* if letter is found within letters code, then toggle interest = 1 */
				if index("&&codes&j", strip(letter)) then   /* strip turns letter variable into a character for comparison */
					&&desc&j = 1;	
				;
			%end;
		end;
		
		drop i letter;
	run;

%mend;

%assign_interests	/* call macro to assign all interest variables */

/* inspect newly populated interest variables (randomly sampled results) */

%sample(
	ds=detail.households_detail, 
	keep=interests &all_interests.,
	obs=25
)

/* -------------------------------------------------------------------------- */
/* ---------- TASK: separate customers by preferred contact method ---------- */
/* -------------------------------------------------------------------------- */

%let req_cols = customer_id contact_preference greeting id_num;		/* macro variable: essential columns required for each data set */

data 
	     contact_post	(keep = &req_cols. full_address)
	    contact_email	(keep = &req_cols. email1)
	excep.contact_dnc	(keep = &req_cols.);

	/* optional: enforce a strict ordering of variables */
	retain customer_id full_address email1 greeting contact_preference;
	set households_detail(keep = &req_cols. address1-address4 postcode email1);

	/* write to each data set for each contact preference*/
	if lowcase(contact_preference) = "post" then do;
		length full_address $ 120;		/* optional: create full_address variable for compact display of address columns */
		label full_address = "Full Customer Address";
		full_address = catx(", ", of address1-address4, postcode); 
		output contact_post;
	end;
	else if lowcase(contact_preference) = "e-mail" then 
		output contact_email;
	else 
		output excep.contact_dnc; 	/* handle other category "DNM" */
run;

/* sort data sets by descending customer ID */

proc sort data=contact_post
		  out=detail.contact_post(drop = id_num);		/* write to DETAIL library */
	by descending id_num;
run;

proc sort data=contact_email 
		  out=detail.contact_email(drop = id_num);
	by descending id_num;
run;

/* view random samples of contact preference data sets */

%sample(ds=detail.contact_post)

%sample(ds=detail.contact_email)

/* ------------------------------------------------------- */
/* PDF REPORT: first 30 observations ordered by customer ID */
/* ------------------------------------------------------- */

options papersize=A3 orientation=landscape;
	%generate_prints(
		dslist 		= detail.contact_post detail.contact_email,
		obs			= 30,		
		label		= 0, 	/* preference: show variable names, not labels */
		filename	= contact_preferences_report
	)
options papersize=A4 orientation=portrait;

/* ------------------------------------------------ */
/* ---------- OPTIONAL VALIDATION CHECKS ---------- */
/* ------------------------------------------------ */

/* EDA: inspect categories and frequencies of title and gender */

proc freq data=households_detail
		  order=freq;

	table 
		title * gender		/* two-way frequency table */
		/ nocol nopercent norow;
run;

%sample(
	ds		= households_detail, 
	obs		= 25,
	keep 	= forename family_name title gender greeting
	where 	= (lowcase(greeting) contains "customer")		/* inspect random samples with filters */
)

/* EDA: inspect households that have multiple members only */

data multiple_members / view=multiple_members;
	set households_detail(keep = customer_id location household_id gender age primary_householder);	
	by location;    								/* group by unique location identifier */
	if not (first.location and last.location);    	/* remove single person households */
run;

title1 "Sample of Household with Multiple Members";
footnote1 height=10pt "Created on: %sysfunc(datetime(), fulldtfmt.)";
	proc print data=multiple_members(obs=15)
			   obs="#";
	run;
title1;
footnote1;

/* EDA: inspect contact preference categories */

proc freq data=households_detail(keep = contact_preference)
		  order=freq;
			
	table contact_preference
		/ nocum;
run;