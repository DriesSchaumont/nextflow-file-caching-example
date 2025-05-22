# Nextflow File Caching Example

This repository provides a small example of large asset (repository) directories not being correctly cached by nextflow.


# Small asset directories cache as expected

## Cleaning the repository

```
nextflow drop DriesSchaumont/nextflow-file-caching-example; rm -rf .nextflow && rm -rf .nextflow.log* && rm -rf work
```

## Example of correct caching

By using `--asset_size small`, the directory `assets_small` is used as the input in the process.

```
nextflow run DriesSchaumont/nextflow-file-caching-example -r c672cdc811daf4ddddc541fb57c7eb44b0c54e62 --asset_size small &&
nextflow drop DriesSchaumont/nextflow-file-caching-example &&
nextflow run DriesSchaumont/nextflow-file-caching-example -r c672cdc811daf4ddddc541fb57c7eb44b0c54e62 --asset_size small -resume
```


# Example of incorrect caching

## Cleaning the repository (again)

```
nextflow drop DriesSchaumont/nextflow-file-caching-example; rm -rf .nextflow && rm -rf .nextflow.log* && rm -rf work
```

## Example of directory not being caches

By using `--asset_size large`, the directory `assets` is used as the input in the process.
It contains 5 extra files containing random data, to increase the size of the directory for demonstration purposes.

```
nextflow run DriesSchaumont/nextflow-file-caching-example -r c672cdc811daf4ddddc541fb57c7eb44b0c54e62 --asset_size large &&
nextflow drop DriesSchaumont/nextflow-file-caching-example &&
nextflow run DriesSchaumont/nextflow-file-caching-example -r c672cdc811daf4ddddc541fb57c7eb44b0c54e62 --asset_size large -resume
```

## Reproducible example by creating in-memory ZFS mount


Create a ramdisk to test the caching of large assets

```bash
sudo modprobe brd rd_nr=1 rd_size=16777216
sudo zpool create zfsnxf ram0
sudo chown -R rcannood:rcannood /zfsnxf
cd /zfsnxf
export NXF_HOME=/zfsnxf/nextflow_home
```

Run workflow once
```bash
nextflow run DriesSchaumont/nextflow-file-caching-example -r db845226d3ba417131e22e127eb501c51b96f6ad --asset_size large
```

    N E X T F L O W   ~  version 25.04.2

    Pulling DriesSchaumont/nextflow-file-caching-example ...
    downloaded from https://github.com/DriesSchaumont/nextflow-file-caching-example.git
    Launching `https://github.com/DriesSchaumont/nextflow-file-caching-example` [small_cori] DSL2 - revision: db845226d3ba417131e22e127eb501c51b96f6ad

    Downloading plugin nf-tower@1.11.2
    executor >  local (3)
    [d5/526ea4] process > foo (Loulou) [100%] 3 of 3 ✔
    96357abec96194ec47a13c810bd84b492c732f2b  test_assets/template.txt

    96357abec96194ec47a13c810bd84b492c732f2b  test_assets/template.txt

    96357abec96194ec47a13c810bd84b492c732f2b  test_assets/template.txt


Drop the repository. This causes the order in which the SimpleFileVisitor traverses the directory to change

```bash
nextflow drop DriesSchaumont/nextflow-file-caching-example
nextflow run DriesSchaumont/nextflow-file-caching-example -r db845226d3ba417131e22e127eb501c51b96f6ad --asset_size large -resume
```


		 N E X T F L O W   ~  version 25.04.2

		Pulling DriesSchaumont/nextflow-file-caching-example ...
		 downloaded from https://github.com/DriesSchaumont/nextflow-file-caching-example.git
		Launching `https://github.com/DriesSchaumont/nextflow-file-caching-example` [amazing_shannon] DSL2 - revision: db845226d3ba417131e22e127eb501c51b96f6ad

		executor >  local (3)
		[f0/16dae1] process > foo (Loulou) [100%] 3 of 3 ✔
		96357abec96194ec47a13c810bd84b492c732f2b  test_assets/template.txt

		96357abec96194ec47a13c810bd84b492c732f2b  test_assets/template.txt

		96357abec96194ec47a13c810bd84b492c732f2b  test_assets/template.txt
