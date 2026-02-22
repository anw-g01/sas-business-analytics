
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
	fmtname = "destcodefmt";
	type = "C";
run;

proc format cntlin=destfmt;		/* create format from data set */
run;

/* create BOOKINGS_DEPOSIT and BOOKINGS_BALANCE data sets */

data bookings_deposit bookings_balance;
	set raw.bookings;

	/* apply destination format mapping */
	length destination $ 30;
	destination = put(destination_code, destcodefmt.);

	day_diff = intck("days", booked_date, departure_date);

	deposit = 0.2 * holiday_cost;
	balance = holiday_cost - deposit;

	if day_diff > 42 then 			
		output bookings_deposit;
	else 
		output bookings_balance;    /* booking made within 6-weeks */

	drop day_diff destination_code;
	label 
		destination = "Destination"
		deposit 	= "Deposit"
		balance 	= "Balance";
run;

proc sort data=bookings_deposit 
		  out=detail.bookings_deposit;
	by booked_date;
run;

proc sort data=bookings_balance 
		  out=detail.bookings_balance;
	by booked_date;
run;

/* inspect samples of both data sets */

%let keep_cols = destination booked_date departure_date holiday_cost deposit balance;
%let col_formats = booked_date departure_date dtfmt. holiday_cost deposit balance nlmnlgbp.2;

%sample(
	ds = detail.bookings_deposit, 
	keep = &keep_cols.,
	formats = &col_formats.,
	label=0
)

%sample(
	ds = detail.bookings_balance,	    /* booking made within 6-weeks */
	keep = &keep_cols.,
	formats = &col_formats.,
	label=1
)

/* -------------------------------------------------------- */
/* PDF REPORT: first 30 observations ordered by booked_date */
/* -------------------------------------------------------- */

options papersize=A3 orientation=landscape;
	%generate_prints(
		dslist=detail.bookings_deposit detail.bookings_balance,
		obs=30,		
		label=0, 	/* preference: don't show labels */
		formats=booked_date departure_date dtfmt. holiday_cost deposit balance nlmnlgbp.2,
		filename=bookings_report
	)
options papersize=A4 orientation=portrait;