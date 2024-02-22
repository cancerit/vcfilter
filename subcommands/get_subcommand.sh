#!/bin/bash

########## LICENCE ##########
# Copyright (c) 2024 Genome Research Ltd
# 
# Author: CASM/Cancer IT <cgphelp@sanger.ac.uk>
# 
# This file is part of vcfilter.
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
# 
# 1. The usage of a range of years within a copyright statement contained within
# this distribution should be interpreted as being equivalent to a list of years
# including the first and last year specified and all consecutive years between
# them. For example, a copyright statement that reads ‘Copyright (c) 2005, 2007-
# 2009, 2011-2012’ should be interpreted as being identical to a statement that
# reads ‘Copyright (c) 2005, 2007, 2008, 2009, 2011, 2012’ and a copyright
# statement that reads ‘Copyright (c) 2005-2012’ should be interpreted as being
# identical to a statement that reads ‘Copyright (c) 2005, 2006, 2007, 2008,
# 2009, 2010, 2011, 2012’.
###########################

# CALLED BY vcfilter, NOT A STANDALONE SCRIPT
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
	
	"${0%/*}"/.env/bin/python "${0%/*}"/subcommands/get_filterables_from_vcf.py "${args[0]}"

}