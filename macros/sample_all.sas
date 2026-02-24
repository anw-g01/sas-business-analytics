
*********************************************************************************************************
*                                                                             							*
*	Name:					sample_all.sas																*
*                                                                             							*
*	Description:			Macro to run a simple random sample on every dataset within a specified 	*
*							library and print the selected observations for each dataset. Calls the		*
*							%sample macro (see sample.sas) for each dataset in the library.				*
* 																										*
*	Parameters:				Optional:																	*
*							- lib: name of the library containing datasets  (default = work)			*			
*							- obs: number of observations to sample from each dataset (default = 12)	*
* 																										*
*	Creation Date:			Wed, 18 Feb 2026 															*
*                                                                             							*
*	Last Updated:			Mon, 23 Feb 2026															*
* 																										*
*	Created By:				Anwarat Gurung																*
*							Katalyze Data																*		
* 																										*
*********************************************************************************************************;

%macro sample_all(lib=work, obs=12);

	/* fetch and store all dataset names (+ count) from library as global macro variables */

	%store_dataset_names(lib=&lib.)	

	/* loop through each dataset and use %sample() - see macros/sample.sas */

	%do i = 1 %to &num_ds.;
		%sample(&&ds&i., obs=&obs.)
	%end;

%mend;