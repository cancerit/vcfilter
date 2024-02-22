#!/usr/bin/env python

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


from __future__ import annotations
import sys
if not sys.version_info >= (3, 7):
    sys.exit('Python 3.7 or greater required!')
from typing import Union
import vcfpy
import argparse


def make_readable(headline: Union[vcfpy.HeaderLine, vcfpy.SimpleHeaderLine]) -> str:
    if isinstance(headline, vcfpy.SimpleHeaderLine):
        read_str = "{} - {}".format(headline.id, headline.description)
    else:
        read_str = "{} - {} - {}".format(headline.id, headline.type, headline.description)
    return read_str


def get_filterables_from_head(vcf: vcfpy.Header) -> str:
    flag: list[str] = ["\nFILTER (flags)\n"] + list(map(make_readable, list(vr.header.get_lines('FILTER'))))
    info: list[str] = ["\nINFO\n"] + list(map(make_readable, list(vr.header.get_lines('INFO'))))
    frmt: list[str] = ["\nFORMAT\n"] + list(map(make_readable, list(vr.header.get_lines('FORMAT'))))

    full: list[str] = flag + info + frmt

    return "\n ".join(full)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("vcf", help="input vcf")
    args = parser.parse_args()

    try:
        vr = vcfpy.Reader.from_path(args.vcf)
    except Exception as e:
        print(e)
        sys.exit('VCF file could not be read!')

    try:
        vh = vr.header
        filts = get_filterables_from_head(vh)
        print(filts)
    except Exception as e:
        print(e)
        sys.exit('Error: could not get fiterables from VCF!')
    finally:
        vr.close()
