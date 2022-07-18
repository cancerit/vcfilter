#!/bin/bash

# CALLED BY VCFilter, NOT A STANDALONE SCRIPT
# "args" are passed in via parent script.

get_usage() {
	cat "${0%/*}"/doc/man_get >&2
	exit 1
}


# MAIN
sub_get() {
	
	if [ "${args[0]}" == 'help' ] || [ "${args[0]}" == '-h' ] ; then
		get_usage
	fi
	if [ "${args[0]}" = '' ] ; then
		echo "Error: VCF not provided!" >&2
		get_usage
	fi
	if [ "${#args[@]}" -gt 1 ] ; then
		echo "Error: too many arguments provided to get; one was expected" >&2
		get_usage
	fi
	
	source "${0%/*}"/.env/bin/activate 
	python "${0%/*}"/subcommands/get_filterables_from_vcf.py "${args[0]}"
	deactivate
}