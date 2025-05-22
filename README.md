# Nextflow File Caching Example

This repository provides a small example of asset (repository) directories not being correctly cached by nextflow.


# Example of incorrect caching

## Cleaning the repository (again)

```
nextflow drop DriesSchaumont/nextflow-file-caching-example > /dev/null; rm -rf .nextflow && rm -f .nextflow.log* && rm -rf work
```

## (Optional?) Setting up a ZFS filesystem in RAM

We've been able to reproduce the behaviour on `zfs` filesystems, but other filesystem/kernel combinations may or may not present the same behavior. 

If a zfs filesystem is not readily available, one can be created using temorary block devices in memory using the `brd` kernel module. This requires a linux based OS.

```bash
sudo modprobe brd rd_nr=1 rd_size=16777216
sudo zpool create zfsnxf ram0
sudo chown -R $(id -u):$(id -g) /zfsnxf
cd /zfsnxf
mkdir nextflow_home
export NXF_HOME=/zfsnxf/nextflow_home
curl -s https://get.nextflow.io | bash
```

## Running the workflow once

Run workflow once
```bash
nextflow run DriesSchaumont/nextflow-file-caching-example -r acecab40435f6d3064f5ffd7c7efa2c60048f463
```

    N E X T F L O W   ~  version 25.04.2

    Pulling DriesSchaumont/nextflow-file-caching-example ...
    downloaded from https://github.com/DriesSchaumont/nextflow-file-caching-example.git
    Launching `https://github.com/DriesSchaumont/nextflow-file-caching-example` [small_cori] DSL2 - revision: acecab40435f6d3064f5ffd7c7efa2c60048f463

    Downloading plugin nf-tower@1.11.2
    executor >  local (3)
    [d5/526ea4] process > foo (Loulou) [100%] 3 of 3 ✔
    96357abec96194ec47a13c810bd84b492c732f2b  test_assets/template.txt
    96357abec96194ec47a13c810bd84b492c732f2b  test_assets/template.txt
    96357abec96194ec47a13c810bd84b492c732f2b  test_assets/template.txt


## Drop the repository and run 

Drop the repository. This causes the order in which the `SimpleFileVisitor` traverses the directory to change

```bash
nextflow drop DriesSchaumont/nextflow-file-caching-example
nextflow run DriesSchaumont/nextflow-file-caching-example -r acecab40435f6d3064f5ffd7c7efa2c60048f463 -resume
```


    N E X T F L O W   ~  version 25.04.2

    Pulling DriesSchaumont/nextflow-file-caching-example ...
    downloaded from https://github.com/DriesSchaumont/nextflow-file-caching-example.git
    Launching `https://github.com/DriesSchaumont/nextflow-file-caching-example` [amazing_shannon] DSL2 - revision: acecab40435f6d3064f5ffd7c7efa2c60048f463

    executor >  local (3)
    [f0/16dae1] process > foo (Loulou) [100%] 3 of 3 ✔
    96357abec96194ec47a13c810bd84b492c732f2b  test_assets/template.txt
    96357abec96194ec47a13c810bd84b492c732f2b  test_assets/template.txt
    96357abec96194ec47a13c810bd84b492c732f2b  test_assets/template.txt

## Removing the temporary ZFS pool

`sudo zpool destroy zfsnxf`