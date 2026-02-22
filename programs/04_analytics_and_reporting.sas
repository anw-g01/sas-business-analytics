
/* -------------------------------------------------------- */
/* ---------- SECTION C: Analytics and Reporting ---------- */
/* -------------------------------------------------------- */

%let all_cols = climbing cycling dancing hiking mountain_biking mountaineering
        		scuba_diving sightseeing skiing snowboarding trail_walking
        		water_sports white_water_rafting yoga;

/* sum each holiday interest variable in HOUSEHOLDS_DETAIL */

proc means data=detail.households_detail(keep = &all_cols)
		   sum maxdec=0 noprint;
	var &all_cols.;
	output out=temp(drop = _TYPE_ _FREQ_)
		sum=;
run;

/* convert columns to rows */

proc transpose data=temp
			   out=marts.interest_counts(rename = (COL1 = count))
			   name=interest;
run;

/* ----------------------------------------------------------------------- */
/* ---------- PDF REPORT: Frequency Counts of Holiday Interests ---------- */
/* ----------------------------------------------------------------------- */

options papersize=A4 orientation=landscape;
ods pdf file="&root.\SAS\reports\holiday_interest_frequency_counts.pdf" 
		style=journal1a;
	title1 "Frequency Counts of Holiday Interests";
	footnote1 height=10pt "Created on: %sysfunc(datetime(), fulldtfmt.)";
		proc sql;
			select
				propcase(tranwrd(interest, "_", " "))
					label="Holiday Interest",
				count
					label="Frequency Count"
					format=comma15.
			from 
				interest_frequency_counts
			order by 
				count desc;
		quit;
	title1;
	footnote1;

	title1 "Frequency Counts of Holiday Interests";
	title2 "By Gender and Country";
	footnote1 height=10pt "Created on: %sysfunc(datetime(), fulldtfmt.)";
		proc tabulate data=detail.households_detail
					  out=marts.interest_counts_by_cg(drop = _TYPE_ _PAGE_ _TABLE_)
				  	  format=comma12.;
		    class gender address4;
		    var &all_cols.;
		    table 
				(&all_cols.) * sum="",
				gender="" * address4="";
			format gender $genderfmt.;												
		run;
	title1;
	footnote1;
ods pdf close;
options papersize=A4 orientation=portrait;

/* Optional: export as a CSV file */

proc export data=marts.interest_counts
			outfile="&root.\Python\data\holiday_interest_counts.csv"
			dbms=csv 
			replace;
run;

proc export data=marts.interest_counts_by_cg
			outfile="&root.\Python\data\holiday_interest_counts_by_country_gender.csv"
			dbms=csv 
			replace;
run;

/* ------------------------------------------------------------- */
/* ---------- EXCEL REPORT: Top 5 Interests by Gender ---------- */
/* ------------------------------------------------------------- */

/* initial single table frequency counts by gender */

proc means data=detail.households_detail(keep = &all_cols gender)
		   sum maxdec=0 nway noprint;
	class gender;
	var &all_cols.;
	output out=counts_by_gender(drop = _TYPE_ _FREQ_)
		sum=;
run;

proc transpose data=counts_by_gender
			   out=test1(rename = (COL1 = count))
			   name=interest;
	id gender;		/* gender tranposed to columns */
run;

proc sql;
	select 
		propcase(tranwrd(interest, "_", " ")) 
			label="Holiday Interest",
		F as female
			label="Female Count"
			format=comma15.,
		M as male 
			label="Male Count"
			format=comma15.,
		sum(F, M) as total
			label="Total"
			format=comma15.
	from	
		test1
	order by
		CALCULATED total desc;
quit;

/* two table frequency by gender */

proc transpose data=counts_by_gender
			   out=counts_by_gender(rename = (COL1 = freq_count))
			   name=interest;
	by gender;		/* use BY instead of ID this time */
run;

proc sql;
	create table counts_by_gender as
		select  
			propcase(tranwrd(interest, "_", " ")) as interest
				label="Holiday Interest",
			gender
				label="Gender",
			freq_count 
				format=comma15.
				label="Frequency Count"
		from 
			counts_by_gender
		order by 
			gender, 
			freq_count desc;
quit;

%let topn = 5; 		/* select the top 5 from each gender */

data counts_by_gender;
	set counts_by_gender;
	by gender descending freq_count;
	if first.gender then 
		rank = 0;
	rank + 1;
	if rank <= &topn.; 		/* retain only the top N for each category */
run;

/* Print with BY gender */

ods excel file="&root.\SAS\reports\top5_interests_by_gender.xlsx"
		  style=journal1a
		  options(
		      sheet_interval="bygroup"
			  suppress_bylines="yes"
			  sheet_label="Gender"
		  );
	title "Holiday Interests by Gender";
	footnote1 height=10pt "Created on: %sysfunc(datetime(), fulldtfmt.)";
		proc print data=counts_by_gender 
				   label noobs;
		    by gender;
		    var freq_count; 
			id interest;
			format gender $genderfmt.;
		run;
	title1;
	footnote1;
ods excel close;