
%macro sample_all(lib=, obs=12);

	/* fetch and store all dataset names (+ count) from library as global macro variables */

	%store_datasets(lib=&lib.)	

	/* loop through each dataset and use %sample() - see macros/sample.sas */

	%do i = 1 %to &num_ds.;
		%sample(&&ds&i., obs=&obs.)
	%end;

%mend;
