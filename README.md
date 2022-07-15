# VCFilter

Simple filtering tool for VCF files

### Background

Scientists requested a tool for filtering VCF files that:  
> i) performs filtering based on a config file - in that way filtering is made shareable and reproducible  
  
> ii) is user-friendly above all else - no perl, vcftools 

So we have made this tool to do exactly that, via a wrapper around bcftools, and some python scripts.  

### Requirements

**Python** >= 3.7.4  
**samtools** == 1.14  
**pysam** == 0.19.1  
**vcfpy** == 0.13.4  
**bcftools** == 1.9

### Installation

clone repository, cd in, and run the following:
```
module load python/3.7.4
python -m venv .env
source .env/bin/activate
pip install -r requirements.txt
deactivate
chmod +x ./vcfriend
```

### Usage

```
module load python/3.7.4 bcftools/1.9
./vcfriend help
```
A simple filter config example is present at `examples/bcf_conf.txt`

More doc forthcoming
