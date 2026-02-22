
proc sql;

	/* create a SHAREHOLDERS data set */
	create table detail.shareholders as 
		select
			*
		from
			raw.loyalty as l
		/* keep only customers that are shareholders  */
		left join 					/* INNER JOIN also valid (LEFT JOIN assumes all shareholders are also customers)*/			
			staging.households as h
			on l.loyalty_id = h.loyalty_id;

	/* create a HOUSEHOLD_ONLY data set */
	create table detail.household_only as 
		select 
			h.*		/* don't include columns from BOOKINGS data set (all empty) */
 		from 
			detail.households_detail as h
		left join 
			raw.bookings as b
			on h.customer_id = b.customer_id
		where 
			booking_id is null;		/* keep only customers that have not made a booking */

quit;