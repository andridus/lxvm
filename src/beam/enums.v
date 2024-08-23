module beam

enum BeamFileResult {
    read_success
		read_corrupt_file_header
    /* Mandatory chunks */
		read_missing_atom_table
		read_obsolete_atom_table
		read_corrupt_atom_table
		read_missing_code_chunk
		read_corrupt_code_chunk
		read_missing_export_table
		read_corrupt_export_table
		read_missing_import_table
		read_corrupt_import_table
		read_corrupt_locals_table
    /* Optional chunks */
		read_corrupt_lambda_table
		read_corrupt_line_table
		read_corrupt_literal_table
		read_corrupt_type_table
};