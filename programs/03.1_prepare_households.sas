

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

/* ---------------------------------------------------------- */
/* ---------- TASK: identify primary householders  ---------- */
/* ---------------------------------------------------------- */

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
	
	if first.location then do;
		household_id + 1;			/* create a HOUSEHOLD_ID variable for each location */
		primary_householder = 1;	/* primary householder is sorted as first */
	end;
	else 
		primary_householder = 0;
run;


/* ------------------------------------------------------------------------- */
/* ---------- TASK 4: derive a variable for each holiday interest ---------- */
/* ------------------------------------------------------------------------- */

/*%include "&root\programs\sectionB_task4.sas";*/


/* -------------------------------------------------------------------------- */
/* ---------- TASK: separate customers by preferred contact method ---------- */
/* -------------------------------------------------------------------------- */

%let req_cols = customer_id contact_preference greeting id_num;	/* essential columns required for each data set */

data 
	contact_post		(keep = &req_cols. full_address)
	contact_email		(keep = &req_cols. email1)
	excep.contact_dnc	(keep = &req_cols.);

	/* optional: enforce a strict ordering of variables */
	retain customer_id full_address email1 greeting contact_preference;
	set households_detail(keep = &req_cols. address1-address4 postcode email1);

	/* write to each data set for each contact preference*/
	if lowcase(contact_preference) = "post" then do;
		length full_address $ 120;		/* optional: create full_address variable for compact display of address columns */
		label full_address = "Full Customer Address";
		full_address = catx(", ", of address1-address4, postcode); 
		output contact_post ;
	end;
	else if lowcase(contact_preference) = "e-mail" then 
		output contact_email;
	else 
		output excep.contact_dnc; 	/* handle other category "DNM" */
run;

/* sort data sets by descending customer ID */

proc sort data=contact_post
		  out=staging.contact_post(drop = id_num);		/* write to STAGING library */
	by descending id_num;
run;

proc sort data=contact_email 
		  out=staging.contact_email(drop = id_num);
	by descending id_num;
run;

/* view random samples of contact preference data sets */

%sample_all(lib=staging)	

/* generate reports of first 30 observations ordered by customer ID */

%generate_prints(
	dslist=staging.contact_post staging.contact_email,
	obs=30,		
	label=0, 	/* preference: show variable names, not labels */
	filename=contact_preferences_report
)

/* ------------------------------------------------ */
/* ---------- OPTIONAL VALIDATION CHECKS ---------- */
/* ------------------------------------------------ */

/* EDA: inspect categories and frequencies of title and gender */

proc freq data=households_detail
		  order=freq;

	table 
		title * gender				/* two-way frequency table */
		/ nocol nopercent norow;
run;

%sample(
	ds=households_detail, 
	obs=25,
	keep = forename family_name title gender greeting
	where = (lowcase(greeting) contains "customer")		/* inspect random samples with filters */
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