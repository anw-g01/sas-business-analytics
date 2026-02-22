
/* -------------------------------------------------------------- */
/* ---------- Preparing the Booking Data for Analytics ---------- */
/* -------------------------------------------------------------- */

%let destlib = staging; 	/* chosen library to store key data sets */

/* create a format from the DESTINATIONS data set */

data &destlib..destfmt;
	set raw.destinations(
		rename=(
			code = start
			description = label
		)
	);
	fmtname = "destcodefmt";
	type = "C";
run;

proc format cntlin=&destlib..destfmt;
run;

/* create BOOKINGS_DEPOSIT and BOOKINGS_BALANCE data sets */

data &destlib..bookings_deposit &destlib..bookings_balance;

	set raw.bookings;

	/* apply destination format mapping */
	length destination $ 30;
	destination = put(destination_code, destcodefmt.);

	day_diff = intck("days", booked_date, departure_date);

	deposit = 0.2 * holiday_cost;
	balance = holiday_cost - deposit;

	if day_diff > 42 then 			
		output &destlib..bookings_deposit;
	else 
		output &destlib..bookings_balance;    /* booking made within 6-weeks */

	drop day_diff;
run;

proc sort data=&destlib..bookings_deposit 
		  out=booking_deposit_sample;
	by booked_date;
run;

proc sort data=&destlib..bookings_balance 
		  out=bookings_balance_sample;
	by booked_date;
run;

/* inspect a sample of BOOKINGS_DEPOSIT */

proc print data=&destlib..bookings_balance(obs=10)
		   obs="#";
	var 
		booked_date departure_date
		holiday_cost deposit balance;
	format 
		booked_date departure_date dtfmt.
		holiday_cost deposit balance nlmnlgbp.2;
run;

/* generate PDF reports */

options papersize=A3 orientation=landscape;

%generate_prints(
	dslist=&destlib..bookings_deposit &destlib..bookings_balance,
	obs=30,		
	label=0, 								/* preference: show variable names rather than labels */
	formats=booked_date departure_date dtfmt. holiday_cost deposit balance nlmnlgbp.2,
	filename=bookings_report
)

options papersize=A4 orientation=portrait;