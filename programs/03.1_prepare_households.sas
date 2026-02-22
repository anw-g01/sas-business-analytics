
*********************************************************************************************
*                                                                             				*
*	Name:					02_clean.sas													*
*                                                                             				*
*	Description:			Completes Section B of the SAS Business Analytics Case Study.	*
*                                                                             				*
*	Creation Date:			Fri, 30 Jan 2026 												*
*                                                                             				*
*	Last Updated:			-																*
* 																							*
*	Created By:				Anwarat Gurung													*
*							Katalyze Data													*		
* 																							*
*********************************************************************************************;

/* ------------------------------------------------ */
/* ---------- SECTION B: Data Management ---------- */
/* ------------------------------------------------ */

%let destlib = detail;		/* chosen library to store HOUSEHOLDS_DETAIL */

data &destlib..households_detail;
	set raw.households(rename = (title = old_title));

	/* ---------------------------- */
	/* ---------- TASK 1 ---------- */
	/* ---------------------------- */

	length greeting $40;
	label greeting = "Customer Greeting";

	/* standardise all title categories */
	if not missing(old_title) then 
		title = propcase(tranwrd(old_title, ".", ""));     /* remove full-stop and convert to title case */

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

	/* construct a greeting message variable */
	if (missing(gender) and missing(forename)) or missing(family_name) then
		greeting = "Dear Customer";
	else
		greeting = catx(" ", "Dear", title, substr(forename, 1, 1), family_name);

	/* ---------------------------- */
	/* ---------- TASK 3 ---------- */
	/* ---------------------------- */

	/* calculate the age of each customer */
	if not missing(dob) then
		age = floor(yrdif(dob, today(), "ACT/ACT"));	/* always round down to last completed year */
	else 
		call missing(age); 								/* set age variable to missing */

	/* create an explicit ranking variable for genders */
	if lowcase(gender) = "f" then 
		gender_rank = 1;
	else if lowcase(gender) = "m" then 
		gender_rank = 2;
	else
		gender_rank = 3;	/* missing values ranked last rather than first */

	drop old_title;
run;


/* ---------- TASK 3 CONTINUED ---------- */

proc sql;
	alter table &destlib..households_detail
		add location char(80);							/* initialise a new location column 	*/

	update &destlib..households_detail
		set location = catx(" ", address1, postcode);	/* household identifier 				*/
quit;

proc sort data=&destlib..households_detail;
	by 
		location			/* sort by the new location variable (each household) 	*/
		gender_rank 		/* prioritise females (missing genders last) 			*/
		descending age;		/* oldest of each gender 								*/
run;

data &destlib..households_detail;
	set &destlib..households_detail;	
	
	/* group by the same sorting variables (order hierarchy) */
	by location gender_rank descending age;	   	
	
	if first.location then do;
		household_id + 1;			/* (TASK 2): create a household id key for each location */
		primary_householder = 1;	/* (TASK 3): identify the primary householder */
	end;
	else 
		primary_householder = 0;
run;


/* ---------------------------- */
/* ---------- TASK 4 ---------- */
/* ---------------------------- */

%include "&root\SAS\programs\sectionB_task4.sas";		/* see sectionB_task4.sas for TASK 4 solution */


/* ---------------------------- */
/* ---------- TASK 5 ---------- */
/* ---------------------------- */

%let destlib2 = staging; 									/* chosen library to store data sets */
%let req_cols = customer_id contact_preference greeting;	/* essential columns required for each data set */

data 
	&destlib2..contact_post(keep = &req_cols full_address id_num)
	&destlib2..contact_email(keep = &req_cols email1 id_num)
	excep.contact_dnc(keep = &req_cols. id_num);

	/* optional: enforce a strict ordering of variables */
	retain customer_id full_address email1 greeting contact_preference;

	/* read in HOUSEHOLD_DETAIL data set for partitioning */
	set households_detail(keep = &req_cols. address1-address4 postcode email1);

	/* create a numerical id column for future sorting */
	id_num = input(customer_id, 10.);	

	/* write to each data set for each contact preference*/
	if lowcase(contact_preference) = "post" then do;
		length full_address $ 120;
		label full_address = "Full Customer Address";
		full_address = catx(", ", of address1-address4, postcode);
		output &destlib2..contact_post ;
	end;
	else if lowcase(contact_preference) = "e-mail" then 
		output &destlib2..contact_email;
	else 
		output excep.contact_dnc; 	/* handle other category "DNM" */
run;

/* sort data sets by descending customer ID */

proc sort data=&destlib2..contact_post
		  out=staging.contact_post_sorted(drop = id_num);
	by descending id_num;
run;

proc sort data=&destlib2..contact_email 
		  out=staging.contact_email_sorted(drop = id_num);
	by descending id_num;
run;

/* view random samples of contact preference data sets */

%sample_all(lib=staging)	

/* generate reports of first 30 observations ordered by customer ID */

%generate_prints(
	dslist=&destlib2..contact_post &destlib2..contact_email,
	obs=30,		
	label=0, 	/* preference: show variable names rather than labels */
	filename=contact_preferences_report
)


/* ------------------------------------------------ */
/* ---------- OPTIONAL VALIDATION CHECKS ---------- */
/* ------------------------------------------------ */

* (TASK 1): inspect categories and frequencies of title and gender;

proc freq data=households_detail
		  order=freq;

	table 
		title * gender				/* two-way frequency table */
		/ nocol nopercent norow;
run;

/* (TASK 1): inspect random samples with filters */

%sample(
	ds=households_detail, 
	obs=25,
	keep = forename family_name title gender greeting
	where = (lowcase(greeting) contains "customer")
)

/* (TASK 3): inspect households that have multiple members only */

data multiple_members / view=multiple_members;
	set &destlib..households_detail(
		keep = customer_id location household_id gender age primary_householder
	);	

	by location;    	* group by unique location identifier;

	/* remove single person households */
	if not (first.location and last.location);    
run;

title1 "Sample of Household with Multiple Members";
footnote1 height=10pt "Created on: %sysfunc(datetime(), fulldtfmt.)";
proc print data=multiple_members(obs=15)
		   noobs;
run;
title1;
footnote1;

/* (TASK 5): inspect contact preference categories */

proc freq data=&destlib..households_detail(keep = contact_preference)
		  order=freq;
	table contact_preference
		/ nocum;
run;