#!/usr/bin/env python

from __future__ import annotations
import sys
if not sys.version_info >= (3, 7):
    sys.exit('Python 3.7 or greater required!')
from typing import Union
import vcfpy
import argparse


def readable(headline: Union[vcfpy.HeaderLine, vcfpy.SimpleHeaderLine]) -> str:
    if isinstance(headline, vcfpy.SimpleHeaderLine):
        read_str = "{} - {}".format(headline.id, headline.description)
    else:
        read_str = "{} - {} - {}".format(headline.id, headline.type, headline.description)
    return read_str


def get_filterables_from_head(vcf: vcfpy.Header) -> list[str]:
    flag: list[str] = ["\nFILTER (flags)\n"] + list(map(readable, list(vr.header.get_lines('FILTER'))))
    info: list[str] = ["\nINFO\n"] + list(map(readable, list(vr.header.get_lines('INFO'))))
    frmt: list[str] = ["\nFORMAT\n"] + list(map(readable, list(vr.header.get_lines('FORMAT'))))

    full: list[str] = flag + info + frmt

    return "\n ".join(full)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("vcf", help="input vcf")
    args = parser.parse_args()

    try:
        vr = vcfpy.Reader.from_path(args.vcf)
        vh = vr.header
    except Exception as e:
        print(e)
        sys.exit('VCF file could not be read!')
    finally:
        vr.close()

    filts = get_filterables_from_head(vh)
    print(filts)
