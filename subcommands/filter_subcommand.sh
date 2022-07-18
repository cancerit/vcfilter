#!/bin/bash

# CALLED BY VCFilter, NOT A STANDALONE SCRIPT
# "args" are passed in via parent script.

DEFAULTTAG="filter"
FILETAG=$DEFAULTTAG
MAXVCF=100
OUT="."

filter_usage() {
	cat "${0%/*}"/doc/man_filter >&2
	exit 1
}

# 'opts' eif:o:qs: h|help --debug
# Using bash array slicing to simulate shifting positional arguments
# "$args[0]" - first argument, n.b. not name of script since this is just an array not CLA
# "${args[@]:1}" - contents of array offset by 1, i.e. missing the 0th element
args_handler() {
	if [[ ! "${args[@]}" ]] ; then
		echo "no arguments provided, exiting" >&2
		echo "for usage: vcfilter filter help" >&2
		exit 1
	fi
	
	while :; do
		case "${args[0]}" in
			-e)
				EXCLUDE=1
				E="-e"
				args=( "${args[@]:1}" )
				;;
			-i)
				INCLUDE=1
				I="-i"
				args=( "${args[@]:1}" )
				;;
			-f)
				if [[ "${args[1]}" =~ [^a-zA-Z0-9\\.\\-] ]] ; then
					echo "Illegal character provided to -f" >&2
					exit 1
				fi
				F='-f'
				FILETAG="${args[1]}"
				args=( "${args[@]:2}" )
				;;
			-h|help)
				filter_usage
				;;
			-o)
				if [ ! -d "${args[1]}" ] ; then
					echo "Error: -o does not appear to be a directory - path provided was ${args[0]}" >&2
					filter_usage
				fi
				OUT="${args[1]}"
				args=( "${args[@]:2}" )
				;;
			-q)
				Q=1
				args=( "${args[@]:1}" )
				# quiet mode
				;;
			-s)
				S='-s'
				SNAME="${args[1]}"
				args=( "${args[@]:2}" )
				;;
			-*)
				echo "Unrecognised flag: ${args[0]}" >&2
				echo "for usage: vcfilter filter help " >&2
				exit 1
				;;
			*)
				break
				# when we reach an argument in the array which does not appear to be a flag
				# break and handle the rest of the array as positional args.
				;;
		esac
	done
	
	# once flags are handled
	if [ "${#args[@]}" -lt 2 ] ; then
		echo "Error: not enough arguments - expecting a config file and at least one VCF" >&2
		echo "for usage: vcfilter filter help" >&2
		exit 1
	fi
	
	if [ "$EXCLUDE" == "$INCLUDE" ] ; then
		echo "Error: filtering must (-e)xclude or (-i)nclude, not both or neither" >&2
		echo "for usage: vcfilter filter help " >&2
		exit 1
	fi
	
	# That should be all our 'options', lets handle 'positionals'
	# config file containing expression describing filtering
	# should be on one line, and should definitely be single quoted
	# so this if goes some way towards preventing misuse
	if [ ! -f "${args[0]}" ] ; then
		echo "Error: could not open filtering expression file at ${args[0]}" >&2
		exit 1
	fi
	if [ -z "${args[0]}" ] ; then
		echo "Error: filtering expression file appears to be empty! - path provided was ${args[0]}" >&2
		exit 1
	fi
	if [[ "$(wc -l <<< "$(cat "${args[0]}")")" -ne 1 || "$(cat "${args[0]}")" =~ ^'.+'$  ]] ; then
		echo "Error: Filtering expression file misformatted! - path provided was ${args[0]}" >&2
		exit 1
	fi
	CONF=${args[0]}
	args=( "${args[@]:1}" )
	
	# the rest should be VCFs
	VCFS=( "${args[@]}" )
	if [ ${#VCFS[@]} -gt $MAXVCF ] ; then
		echo "Error: That's too many VCFs!" >&2
		echo "Maximum allowed number of VCFs = $MAXVCF"
		exit 1
	fi
	
	args=0 # here endeth args
	# arguments handled
}

# info for checking/debug/education/curiosity
filter_info() {
	bcf_example_call=$(printf "bcftools filter %s%s %s %s %s %s %s [VCF]" "${E}" "${I}" "$(cat "$CONF")" "${S}" "${SNAME}" "${F}" "${FILETAG}")
	echo -e "\nVCF/s: ${VCFS[*]}\nOUTPUT DIRECTORY: ${OUT}\nFILTER EXPRESSION: $(cat "$CONF")\nCOMMAND: $bcf_example_call\n" >&2
}

# function to perform filtering
# Since this function is called as a background process
# Any functionality added here is likely to give unexpected behaviour!!!
# run bcf_call as command with bash -c, in child shell.
# bash -c avoids wordsplitting issues if you try to run bcf_call in this script directly
# could alternately use eval
filter_engine() {
		bash -c "$bcf_call" > "$OUTPATH"
}


# MAIN
sub_filter() {
	
	args_handler
	
	# unless you've asked me to be quiet:
	if [ "$Q" == '' ] ; then
		filter_info
	fi
	
	# meat
	for V in "${VCFS[@]}" ; do
		if [[ ! -f "${V}" || ! ${V} =~ .+\..cf.* ]] ; then
			echo "Error: could not open VCF at ${V}" >&2
			exit 1
		fi
		
		# construct call to bcf and export it for use in child shell
		bcf_call=$(printf "bcftools filter %s%s %s %s %s %s" "${E}" "${I}" "$(cat "$CONF")" "${S}" "${SNAME}" "${V}")
		
		# create output path
		# ## remove longest match of */ from beginning of string (remove path)
		# % remove shortest match of ?cf* from end of string (remove e.g. '.bcf.gz')
		# if checks for trailing slash in provided output dir
		VOUT=${V##*/}
		if [ "${OUT: -1}" == "/" ] ; then
			OUTPATH="${OUT}${VOUT%?cf*}${FILETAG}.vcf"
		else
			OUTPATH="${OUT}/${VOUT%?cf*}${FILETAG}.vcf"
		fi
		
		{ filter_engine || { echo "Error running bcftools" >&2; kill $$; }; } &
		# continue without waiting for command to finish with & (which must come at end of line)
		# i.e. parallelise filtering multiple VCFs
		# because this line executes in parallel subshells, which are also run as background commands, executing a function
		# actually getting the script to exit on failure is really tricky because scoping/back-passing nightmares.
		# hence "kill $$" - it works well in my testing
	done
	wait
	
	echo 'VCF/s filtered' >&2
}