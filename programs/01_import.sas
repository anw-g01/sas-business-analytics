
*************************************************************************************************
*                                                                             					*
*	Name:					01_import.sas														*
*                                                                             					*
*	Description:			Load all input CSV and DAT files into the RAW SAS library 			*
*							and produce a PROC CONTENTS summary PDF report of all data sets.	*
*                                                                             					*
*	Creation Date:			Wed, 28 Jan 2026 													*
*                                                                             					*
*	Last Updated:			Mon, 23 Feb 2026													*
* 																								*
*	Created By:				Anwarat Gurung														*
*							Katalyze Data														*		
* 																								*
************************************************************************************************;

/* 1. HOUSEHOLDS */

data raw.households;
	infile input("Households.csv")
		dsd 
		dlm=","
		firstobs=2;

	/* set lengths explicitly for primary/foreign keys */
	length 
		customer_id 		$7
		loyalty_id 			$10;

	input
		customer_id			
		family_name 		: $30.
		forename 			: $20.
		title 				: $5.
		gender 				: $1.
		dob 				: date9.
		loyalty_id 			
		address1 			: $50.
		address2 			: $30.
		address3 			: $30.
		address4 			: $30.
		postcode     		: $10.
		email1 				: $40.
		contact_preference 	: $10.
		interests 			: $30.		
		customer_startdate 	: date9.
		contact_date 		: date9.;	

	label
		customer_id 		= "Customer Identification"
		postcode 			= "Postcode"
		family_name 		= "Family Name"
		forename 			= "Forename"
		gender 				= "Gender"
		title 				= "Title"
		address1 			= "Address1"
		address2 			= "Address2"
		address3 			= "Address3"
		address4 			= "Address4"
		customer_startdate 	= "Customer Enrolment Date"
		contact_date 		= "Date Customer Last Contacted"
		dob 				= "Date of Birth"
		contact_preference 	= "Customers Contact Preference"
		loyalty_id 			= "Loyalty Identification"
		interests 			= "Customer Interests"
		email1 				= "Email Address";
run;


/* 2. BOOKINGS */

data raw.bookings;
	infile input("Bookings.csv")
		dsd 
		dlm=","
		firstobs=2;

	/* set lengths explicitly for primary/foreign keys */
	length 
		customer_id 		$7
		booking_id 			$7
		destination_code    $2;

	input 
		family_name 		: $30.
		brochure_code 		: $1.
		room_type 			: $8. 
		booking_id 			
		customer_id 		
		booked_date 		: date9.
		departure_date 		: date9.
		duration
		pax
		insurance_code		: $1.
		holiday_cost 		: nlmnlgbp.2
		destination_code	;

	label 
		booking_id 			= "Booking ID"
		customer_id 		= "Customer ID"
		family_name 		= "Family Name"
		brochure_code 		= "Brochure of Destination"
		booked_date 		= "Date Customer Booked Holiday"
		departure_date 		= "Holiday Departure Date"
		duration 			= "Number of Nights"
		pax 				= "Number of Passengers"
		insurance_code 		= "Customer Added Insurance"
		room_type		 	= "Room Type"
		holiday_cost 		= "Total Cost (�) of Holiday"
		destination_code 	= "Destination Code";
run;


/* 3. DESTINATIONS */

data raw.destinations;
	infile input("Destinations.csv")
		dsd 
		dlm="," 
		firstobs=2;

	/* set lengths explicitly for primary/foreign keys */
	length 
		code      			$2;

	input
		code 				: $2.
		description 		: $30.;

	label 
		code 				= "Destination Code"
		description 		= "Description";
run; 


/* 4. LOYALTY */

data raw.loyalty;
	infile input("Loyalty.dat")		/* tab delimitted DAT file */
		dsd 
		dlm="09"x					/* tab character */
		firstobs=2;

	/* set lengths explicitly for primary/foreign keys */
	length 
		account_id 			$7
		loyalty_id 			$10;	

	input
		account_id
		loyalty_id
		invested_date		: date9.
		initial_value 		
		investor_type		: $10.
		current_value		;

	label 
		loyalty_id 			= "Loyalty Identification"
		account_id 			= "Customer Account Number"
		initial_value 		= "Initial Share Value"
		investor_type 		= "Type of Investor"
		current_value 		= "Current Share Value"
		invested_date 		= "Investment Date";
run;

/* ------------------------------- */
/*  PDF REPORT: DATA SET CONTENTS  */
/* ------------------------------- */

%generate_contents(lib=raw)    		/* generate a PROC CONTENTS report for each data set within the RAW library */

/* ------------------------------------------- */
/*  OPTIONAL: PRINT AND VIEW DATA SET SAMPLES  */
/* ------------------------------------------- */

%sample_all(lib=raw, obs=8)			/* print a randomised selection of samples from each data set in specified library */