
*********************************************************************************************************
*                                                                             							*
*	Name:					03.2_prepare_bookings.sas													*
*                                                                             							*
*	Description:			Prepare the BOOKINGS data set by mapping destination codes to 				*
*							descriptions, calculating deposit and balance amounts based on booking		*
*							dates, and separating records into deposit and balance data sets. 			*
*							Output sorted detail tables and generate a sample PDF report.				*
*                                                                             							*
*	Creation Date:			Fri, 20 Feb 2026															*
*                                                                             							*
*	Last Updated:			Mon, 23 Feb 2026															*
* 																										*
*	Created By:				Anwarat Gurung																*
*							Katalyze Data																*		
* 																										*
*********************************************************************************************************;

/* ---------------------------------------------------------------------------------- */
/* ---------- TASK: create BOOKINGS_DEPOSIT and BOOKINGS_BALANCE data sets ---------- */
/* ---------------------------------------------------------------------------------- */

/* create a format from the DESTINATIONS data set */

data destfmt;
	set raw.destinations(
		rename=(
			code = start
			description = label
		)
	);
	fmtname = "destcodefmt";	/* name of format */
	type = "C";					/* character type format */
run;

proc format cntlin=destfmt;		/* create format from data set */
run;

/* create BOOKINGS_DEPOSIT and BOOKINGS_BALANCE data sets */

data bookings_deposit bookings_balance;
	set raw.bookings;

	/* apply destination format mapping */
	length destination $ 30;
	destination = put(destination_code, destcodefmt.);

	/* calculate the number of exact days between booked_date and departure_date */
	day_diff = intck("days", booked_date, departure_date);

	deposit = 0.2 * holiday_cost;
	balance = holiday_cost - deposit;

	if day_diff > 42 then 			/* more than 6-weeks between booking and departure */
		output bookings_deposit;
	else 
		output bookings_balance;    /* booking made within 6-weeks */

	/* optional: variable clean-up and labelling */
	drop day_diff destination_code;
	label 
		destination = "Destination"
		deposit 	= "Deposit"
		balance 	= "Balance";
run;

/* sort both data sets by ascending booked_date */

proc sort data=bookings_deposit 
		  out=detail.bookings_deposit;
	by booked_date;
run;

proc sort data=bookings_balance 
		  out=detail.bookings_balance;
	by booked_date;
run;

/* inspect random samples of both data sets */

%let keep_vars = destination booked_date departure_date holiday_cost deposit balance;
%let var_formats = booked_date departure_date dtfmt. holiday_cost deposit balance nlmnlgbp.2;

%sample(
	ds 		= detail.bookings_deposit, 
	keep 	= &keep_vars.,
	formats = &var_formats.,
	label	= 0								/* preference: view without labels */
)

%sample(
	ds 		= detail.bookings_balance,	    /* booking made within 6-weeks */
	keep 	= &keep_vars.,
	formats = &var_formats.,
	label	= 1								/* preference: view with labels */
)

/* -------------------------------------------------------- */
/* PDF REPORT: first 30 observations ordered by booked_date */
/* -------------------------------------------------------- */

options papersize=A3 orientation=landscape;
	%generate_prints(
		dslist		= detail.bookings_deposit detail.bookings_balance,
		obs			= 30,		
		label		= 0, 	/* preference: don't show labels */
		formats		= booked_date departure_date dtfmt. holiday_cost deposit balance nlmnlgbp.2,
		filename	= bookings_report	/* PDF file name (without extension) */
	)
options papersize=A4 orientation=portrait;