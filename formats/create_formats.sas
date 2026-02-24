
*****************************************************************************************************
*                                                                             						*
*	Name:					create_formats.sas														*
*                                                                             						*
*	Description:			Creates reusable formats for dates, datetimes, gender, 					*
*							and holiday interest codes.												*
*                                                                             						*
*	Creation Date:			Wed, 18 Feb 2026 														*
*                                                                             						*
*	Last Updated:			Mon, 23 Feb 2026														*
* 																									*
*	Created By:				Anwarat Gurung															*
*							Katalyze Data															*		
* 																									*
*****************************************************************************************************;

proc format library=formats;
	
	picture fulldtfmt (default=22)
        other = "%a, %d %3B %Y %0H:%0M" (datatype=datetime);	/* for date format codes see docs: https://documentation.sas.com/doc/en/proc/1.0/p0n990vq8gxca6n1vnsracr6jp2c.htm */

    picture dtfmt (default=16)
        other = "%d %3B %Y" (datatype=date);

	value $genderfmt
		"M" 	= "Male"
		"F" 	= "Female"
		other 	= "";

	value $interestfmt
		"A", "K", "L" 	= "Mountaineering"
		"B" 			= "Water Sports"
		"C", "X"		= "Sightseeing"
		"D" 			= "Cycling"
		"E" 			= "Climbing"
		"F", "W" 		= "Dancing"
		"H", "G" 		= "Hiking"
		"J" 			= "Skiing"
		"M" 			= "Snowboarding"
		"N" 			= "White Water Rafting"
		"P", "Q", "R"	= "Scuba Diving"
		"S"				= "Yoga"
		"T", "U" 		= "Mountain Biking"
		"V", "Y", "Z" 	= "Trail Walking"
		other			= "";
        
run;

/* optional test: View all formats as a data set */

title1 "%nrstr(%sysfunc(datetime(), fulldtfmt.))";		/* test datetime picture format within titles */
title2 "%sysfunc(datetime(), fulldtfmt.)";
	footnote1 height=10pt "Created on: %sysfunc(datetime(), fulldtfmt.)";
		proc format library=shared
					cntlout=fmt_list(keep = fmtname -- length);
		run;

		proc print data=fmt_list 
				noobs;
		run;
	title1;
footnote1;

/* test interest code format */

data interests_example;
	input code $1.;
	desc = put(code, interestfmt.);
datalines;
A
B
X
Z
P
Q
F
Z
K
D
J
run;

proc print data=interests_example
		   noobs;
run;