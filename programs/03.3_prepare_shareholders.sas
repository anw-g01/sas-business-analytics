
*************************************************************************************************
*                                                                             					*
*	Name:					03.3_prepare_shareholders.sas										*
*                                                                             					*
*	Description:			Create SHAREHOLDERS and HOUSEHOLD_ONLY data sets by joining 		*
*							LOYALTY, HOUSEHOLDS, and BOOKINGS data sets. Identify shareholder	*
*							customers via loyalty IDs and isolate household records with 		*
*							no recorded bookings. Output both tables to the DETAIL library.		*
*                                                                             					*
*	Creation Date:			Fri, 20 Feb 2026 													*
*                                                                             					*
*	Last Updated:			Mon, 23 Feb 2026													*
* 																								*
*	Created By:				Anwarat Gurung														*
*							Katalyze Data														*		
* 																								*
************************************************************************************************;

/* create SHAREHOLDERS and HOUSEHOLD_ONLY data sets using PROC SQL joins */

proc sql;

	/* create a SHAREHOLDERS data set */
	create table detail.shareholders(drop = loyalty_id2) as 
		select
			*		/* use rename= and drop= to drop second loyalty_id joining key without listing all columns */
		from
			raw.loyalty as l
		/* keep only customers that are shareholders - INNER JOIN also valid (LEFT JOIN assumes all shareholders are also customers)*/
		left join 						
			staging.households(rename = (loyalty_id = loyalty_id2)) as h
			on l.loyalty_id = h.loyalty_id2;

	/* create a HOUSEHOLD_ONLY data set */
	create table detail.household_only as 
		select 
			h.*		/* don't include columns from BOOKINGS data set (all empty due to the anti-join) */
 		from 
			detail.households_detail as h
		left join 
			raw.bookings as b
			on h.customer_id = b.customer_id
		where 
			booking_id is null;		/* ANTI-JOIN: keep only customers that have not made a booking */

quit;