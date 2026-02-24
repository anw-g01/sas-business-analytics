
*************************************************************************************************
*                                                                             					*
*	Name:					04_analytics_and_reporting.sas										*
*                                                                             					*
*	Description:			Calculate frequency counts for each holiday interest, reshape 		*
*							results for reporting, and produce PDF and CSV outputs including 	*
*							breakdowns by gender and country. Identify and report the top 		*
*							five interests per gender and generate an Excel summary file.		*
*                                                                             					*
*	Creation Date:			Fri, 20 Feb 2026 													*
*                                                                             					*
*	Last Updated:			Mon, 24 Feb 2026													*
* 																								*
*	Created By:				Anwarat Gurung														*
*							Katalyze Data														*		
* 																								*
************************************************************************************************;

/* -------------------------------------------------------------------------------- */
/* ---------- TASK: calculate frequency counts for each holiday interest ---------- */
/* -------------------------------------------------------------------------------- */

/* sum each holiday interest variable in HOUSEHOLDS_DETAIL */

proc means data=detail.households_detail(keep = &all_interests.)
		   sum maxdec=0 noprint;
	var &all_interests.;	/* sum all holiday interest variables */
	
	output out=interest_fcounts(drop = _TYPE_ _FREQ_)
		sum=;
run;

/* convert wide to long format (columns to rows) */

proc transpose data=interest_fcounts
			   out=marts.interest_fcounts(
			       rename = (
					   COL1 = count
					   _LABEL_ = interest	/* use interest labels for display */
				   )
				   drop = _NAME_
			   );
run;

/* ------------------------------------------------- */
/* PDF REPORT: frequency counts of holiday interests */
/* ------------------------------------------------- */

options papersize=A4 orientation=portrait;
	ods pdf file="&root.\reports\holiday_interest_frequency_counts.pdf" 
			style=journal1a;
		
		/* report print no. 1 */
		title1 "Frequency Counts of Holiday Interests";
		footnote1 height=10pt "Created on: %sysfunc(datetime(), fulldtfmt.)";
			proc sql;
				select
					interest
						label="Holiday Interest",
					count
						label="Frequency Count"
						format=comma15.
				from 
					marts.interest_fcounts
				order by 
					count desc;
			quit;
		title1;
		footnote1;

		/* report print no. 2 */
		title1 "Frequency Counts of Holiday Interests";
		title2 "By Gender and Country";
		footnote1 height=10pt "Created on: %sysfunc(datetime(), fulldtfmt.)";
			proc tabulate data=detail.households_detail
						  out=marts.interest_fcounts_by_cg(drop = _TYPE_ _PAGE_ _TABLE_)
					  	  format=comma12.;
			    class gender address4;
			    var &all_interests.;
			    table 
					(&all_interests.) * sum="",
					gender="" * address4="";
				format gender $genderfmt.;												
			run;
		title1;
		footnote1;

	ods pdf close;
options papersize=A4 orientation=portrait;

/* optional: export as a CSV file for python visualisations (see python folder) */

proc export data=marts.interest_fcounts_by_cg
			outfile="&root.\Python\data\holiday_interests_by_country_gender.csv"
			dbms=csv 
			replace;
run;

/* --------------------------------------------------------------------------- */
/* ---------- TASK: report the top 5 interests classified by gender ---------- */
/* --------------------------------------------------------------------------- */

/* calculate holiday interest frequency counts by gender */

proc means data=detail.households_detail(keep = &all_interests. gender)
		   sum maxdec=0 nway noprint;
	class gender;
	var &all_interests.;	/* macro variable with all holiday interest variables (see 03.1_preparehouseholds.sas program) */

	output out=fcounts_by_gender(drop = _TYPE_ _FREQ_)
		sum=;
run;

/* convert wide to long format (columns to rows) */

proc transpose data=fcounts_by_gender
			   out=fcounts_by_gender(
			 	   rename = (
					   COL1 = freq_count
					   _LABEL_ = interest	/* use interest labels for display */
					   )
				   drop = _NAME_
			   );
	by gender;		/* put gender as rows (NOT columns using ID) */
run;

/* sort descending freq counts by gender */

proc sort data=fcounts_by_gender;
	by
		gender 
		descending freq_count;
run;

/* filter for the top N interests by gender */

%let topn = 5; 				/* select the top N from each gender */

data marts.fcounts_by_gender(drop = rank);
	set fcounts_by_gender;
	by gender descending freq_count;

	if first.gender then 
		rank = 0;
	rank + 1;
	if rank <= &topn.; 		/* retain only the top N for each category */

	label 
		interest 	= "Holiday Interest"
		freq_count 	= "Frequency Count";
run;

/* -------------------------------------------------- */
/* EXCEL REPORT: top 5 interests classified by gender */
/* -------------------------------------------------- */

ods excel file="&root.\reports\top5_interests_by_gender.xlsx"
		  style=journal1a
		  options(
		      sheet_interval="bygroup"  
			  suppress_bylines="yes" 
			  sheet_label="Gender"
		  );
	title "Holiday Interests by Gender";
	footnote1 height=10pt "Created on: %sysfunc(datetime(), fulldtfmt.)";
		proc print data=marts.fcounts_by_gender
				   noobs label;
		    by gender;
		    var freq_count; 
			id interest;
			format gender $genderfmt.;
		run;
	title1;
	footnote1;
ods excel close;