
%macro store_datasets(lib=work);

	data _NULL_;
		set sashelp.vtable(
				where = (
					upcase(memtype) = "DATA" 					/* don't filter for views */
					and upcase(libname) = upcase("&lib."))		
				keep = libname memname memtype
			) end=last_obs;										/* NOBS= is unavaible for VIEWS */

		/* concatenate as <libname>.<memname> */
		ds = catx(".", libname, memname);

		/* store as global macro variables */
		call symputx(cats("ds", _N_), ds, "G");

		/* store the no. of datasets as a macro variable */
		if last_obs then call symputx("num_ds", _N_, "G");		
	run;

%mend;
