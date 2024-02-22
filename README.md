# VCFilter

Simple filtering tool for VCF files

### Background

Scientists requested a tool for filtering VCF files that:  
> i) performs filtering based on a config file - in that way filtering is made shareable and reproducible  
  
> ii) is user-friendly above all else - no perl, vcftools 

So we have made this tool to do exactly that, via a wrapper around bcftools, and some python scripts.  

### Requirements

**Python** >= 3.7.4  
**vcfpy** >= 0.13.4  
**bcftools** >= 1.9

In all cases lower versions may work, however they have not been tested, and you would need to modify the version checks in vcfilter.

### Installation

clone repository, cd in, and run the following:
```
python -m venv .env
source .env/bin/activate
pip install -r requirements.txt
deactivate
chmod +x ./vcfilter
```

Make sure to add the location of vcfilter to PATH if you want to call the tool system wide, without specifying the absolute filepath.

### Usage

```
./vcfilter help
```
Look here first


The program has functions separated into subcommands. These are:
```
vcfilter get -  Given a VCF file, prints basic filterable (FILTER, INFO, and FORMAT) items in a human readable format
 
vcfilter filter - Given one or more VCF file and a filtering config text file, filter VCF/s according to config file  
 
vcfilter expression - Display the expression manual from bcftools as a reference for writing filtering configs
```

#### Filtering Configs & Examples:
vcfilter filter  is a wrapper around bcftools allowing for filtering conditions to be delivered via a config file. This is a text file and should contain a single line, enclosed by single quotes, that defines an expression used to select variants.

For example, to select for variants where CLPM = 0 and ASMD >= 140, and which were **not** flagged as 'HP' (set by [caveman](https://github.com/cancerit/CaVEMan) and [hairpin](https://github.com/cancerit/hairpin-wrapper)), the config file should contain the following:
```
'CLPM=0 & ASMD>=140 & FILTER!~"HP"'
```
This example config is available in `examples`

To **remove** all variants which **don't match** our filtering condition, we use the filter subcommand with the -i(nclude) flag (i.e. **only keep matches**):
```
vcfilter filter -i examples/Mathijs.filter path/to/VCF
```

To **remove** all variants which **do match** this condition, we use the filter subcommand with the -e(xclude) flag (i.e **remove all matches**)
```
vcfilter filter -e /lustre/scratch124/casm/team78pipelines/reference/shared/vcfilter/Mathijs.filter path/to/VCF
```

If, rather than removing items, you'd simply like to flag them with a specific FILTER flag, you can use the -s(oft) flag:
```
vcfilter filter -s GOOD -i /lustre/scratch124/casm/team78pipelines/reference/shared/vcfilter/Mathijs.filter path/to/VCF
```
Variants which match your condition will now have the GOOD flag in their FILTER entry - note that this will remove all other flags. 

If you want to output to a specific directory, we can do this with the -o(utput) flag:
```
vcfilter filter -s GOOD -o myfolder -i /lustre/scratch124/casm/team78pipelines/reference/shared/vcfilter/Mathijs.filter path/to/VCF
```
Now your VCF will be output to myfolder/ 

VCFs output by the command will have the tag '.filter.' appended to the filename by default.
If you want to name the filtered VCFs in a more informative way, you can change this tag with the -f(iletag) flag:
```
vcfilter filter -s GOOD -o myfolder -f 'CLPM0' -e /lustre/scratch124/casm/team78pipelines/reference/shared/vcfilter/Mathijs.filter path/to/VCF
```
Your ouptut VCF will now have the tag '.CLPM0.' appended to the filename.

To filter many VCFs at once, simply pass more paths to VCF files at the end of the command
```
vcfilter filter -s GOOD -o myfolder -f 'CLPM0' -e /lustre/scratch124/casm/team78pipelines/reference/shared/vcfilter/Mathijs.filter VCF1 VCF2 VCF3...  
vcfilter filter -s GOOD -o myfolder -f 'CLPM0' -e /lustre/scratch124/casm/team78pipelines/reference/shared/vcfilter/Mathijs.filter VCF_folder/*.vcf
```

For guidance on making your own config file, see [here](https://samtools.github.io/bcftools/howtos/filtering.html) and [here](https://samtools.github.io/bcftools/bcftools.html#expressions). The latter is available within vcfilter via  vcfilter expression.
