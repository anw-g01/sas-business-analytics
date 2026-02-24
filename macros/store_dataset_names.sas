
*************************************************************************************************************
*                                                                             								*
*	Name:					store_dataset_names.sas																*
*                                                                             								*
*	Description:			Macro to retrieve all dataset names from a specified library and store 			*
*							them as global macro variables for iterative processing by other macros.		*
*																											*											
*	Parameters:				Optional:																		*
*							- lib: name of the library containing datasets to sample from (default = work)	*
*                                                                             								*
*                                                                             								*
*	Creation Date:			Fri, 20 Feb 2026 																*
*                                                                             								*
*	Last Updated:			Mon, 23 Feb 2026																*
* 																											*
*	Created By:				Anwarat Gurung																	*
*							Katalyze Data																	*		
* 																											*
*************************************************************************************************************;

%macro store_dataset_names(lib=work);

	/* loop through all datasets in the specified library and store their names as global macro variables */
	data _NULL_;
		set sashelp.vtable(		/* find all datasets in the specified library from the VTABLE view */
				where = (
					upcase(memtype) = "DATA" 					/* don't filter for views */
					and upcase(libname) = upcase("&lib."))		
				keep = libname memname memtype
			) end=last_obs;										

		/* concatenate as <libname>.<memname> */
		ds = catx(".", libname, memname);

		/* store as global macro variables */
		call symputx(cats("ds", _N_), ds, "G");

		/* store the no. of datasets (count) as a global macro variable */
		if last_obs then call symputx("num_ds", _N_, "G");		/* use _N_ as NOBS= is unavailable for VIEWS */
	run;

%mend;