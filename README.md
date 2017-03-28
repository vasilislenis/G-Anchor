# G-Anchor: A novel approach for cross-species comparison
-----------------------------------------------------------
G-Anchor is a novel approach for large genomes comparison exploiting highly conserved sequences as evolutionary-stable "anchors". 
The pipeline maps a newly sequenced genome (assembled in scaffolds) on a reference genome in a fast way and without the need of a super computer. Instead of aligning the whole reference genome against the scaffolds of the target genome, it maps the Highly Conserved Elements (HCE) up to the target scaffolds and uses them as anchor points in order to put the scaffolds in the right order.

### Availability:
G-Anchor pipeline is available for any Linux and macOSX distridution.
Download the appropriate zipped file for your system and unzip it:
```
tar -xvzf G-Anchor_LINUX_RELEASE_V1.0s.tar.gz
```
### Testing G-Anchor:
In order to test G-Anchor, a small sample of data is embedded. The sample contains cattle's chromosome 28 as reference and 2 scaffolds of yak genome as target.
Run the sample data with the following command:
  ```
  ./G-Anchor_controller.sh -s 28 -e 28 -t yak
  ```

### What is inside the G-Anchor's package:
* **G-Anchor_V1.0s:** The G-Anchor's pipeline folder.
* **G-Anchor_preProcessing_V1.0s:** The G-Anchor's preprocessing pipeline.

Inside G-Anchor's pipeline folder you can find:
* **G-Anchor_controller.sh:** The wrapper script to run the program.
* **G-Anchor.sh:** G-Anchor's main script.
* **bin/:** The folder with the tools
* **INPUT/:** The folder with all the data that G-Anchor needs as input.

Inside G-Anchor's preprocessing pipeline folder you can find:
* **GA_preProcessing_controler.sh:** The wrapper script to run the program.
* **G-Anchor_preProcessing.sh:** G-Anchor's preprocessing main script.
* **bin/:** The folder with the tools
* **P_HCEs/:** The folder with the coordinates of the HCE databank as it is predicted based on the reference genome which was used initially for the alignments construction. The preProcessing pipeline will transform these coordinates to the reference of choice.

 By default, **P_HCEs/** folder contains the HCE databank coordinates that is predicted from the UCSC multiple alignments of 99 genomes (see the list of the genomes in G-Anchor's paper) against human genome (hg38). The user can use them or replace them with the HCE databank coordinates of its choice, keeping consistency on the format (The HCE coordinates should be stored in _.bed_ format in the form: most_conserved_chr*.bed, where * is the number of the chromosome). 

### Preparing your data:
#### Preparing your data for G-Anchor:

G-Anchor needs 4 inputs embedded the **INPUT/** folder that are described as follows:
 1. Reference chromosomes in _.2bit_ format in the **INPUT/GENOMES_DB/REFERENCE** folder.
 2. Target scaffolds (one file) in  _.2bit_ format in the **INPUT/GENOMES_DB/TARGET** folder.
 3. HCE databank in _fasta_ format in the **INPUT/HCES_DB** folder.
 4. The coordinates of the HCE on the reference genome in _.bed_format in the **INPUT/HCES_DB_coords** folder.

##### File names:

The reference chromosomes files should be in the form: **chr*.2bit**, where * is the number of chromosome.<br />
The target genome should be on the form **name_of_species.2bit**.<br />
The HCE databank files should be in the form: **most_conserved_chr*.fa**, where * is the number of the chromosome.<br />
The HCE coordinate files should be in the form: **most_conserved_chr*.bed**, where ** * ** is the number of the chromosome.

More details about the file formats that G-Anchor uses can be found at:
https://genome.ucsc.edu/FAQ/FAQformat

#### Preparing your data for the preprocessing pipeline:

This is an optional step, required when the reference genome, against which the target is to be anchored, is changed.

G-Anchor preprocessing pipeline comes with a prebuilt HCE coordinates set (P_HCEs folder) predicted on human (Hg38) genome. 
In case that you want to change the coordinates of the HCE databank into your chosen reference genome, you need:
 1. Human genome in one fasta file as hg38.fa or as hg38.2bit (can be found in **G-Anchor_V1.0s/INPUT/GENOMES_DB/REFERENCE** folder, see "Existing HCE databanks and INPUT sample" section below). 
 2. The new reference sequences in chromosome form stored in **G-Anchor_V1.0s/INPUT/GENOMES_DB/REFERENCE**, in _.2bit_ format.
 

### How to run:
#### Running G-Anchor pipeline:

You can run G-Anchor pipeline in two modes:
* Using the interactive mode: Run the controller with "-r" option:
 ```
 ./G-Anchor_controller.sh -r 
 ```
 The terminal will ask you for the details that you have to give as inputs.

* Giving the arguments that you want into the command line and the pipeline will run automatically:
 
 Command examples:
 ```
 ./G-Anchor_controller.sh -s 1 -e 29 -t yak 
 ```
  The command example triggers the pipeline to run for all the cattle chromosomes with yak genome on a single core without any parameters anabled (slow run).
  ```
 ./G-Anchor_controller.sh -s 1 -e 29 -t yak -p 8 --ooc --fastMap
  ```
   The command example triggers the pipeline to run all the cattle chromosomes with yak genome, in a multicore mode with 8 threads and fastMap and ooc anabled (faster way, recommented).

* With "-h/--help" argument you can see the help page with all the options that are provided.
 ```
 ./G-Anchor_controller.sh -h
 ```
 

#### Running preprocessing pipeline:

You can run the preprocessing pipeline in two modes:
 
 * Using the interactive mode: Run the controller with "-r" option:
 ```
 ./GA_preProcessing_controler.sh -r 
 ```
 The terminal will ask you for the details that you have to give as inputs.

* Giving the arguments that you want into the command line and the pipeline will run automatically:
 
 Command examples:
  ```
  ./GA_preProcessing_controler.sh -a 22 -b 29 -n BosTau7 -g /absolute_path_to_your_GENOME_DB/ --ooc
  ```
 The command example triggers the pipeline to run in order to calculate the HCE based on the new reference genome (BosTau7). It runs on a single core with the ooc parameter anabled (recomented). 
 
* With "-h/--help" argument you can see the help page with all the options that are provided.
  
 ```
 ./GA_preProcessing_controler.sh -h
 ```

### Existing HCE databanks and INPUT sample:
 
To use the pipelines with the existing HCE databanks you can download the data that are provided in the following address:

http://www.filehosting.org/file/details/652340/HCE_DATABANKS_V1.0.tar.gz

In order to test G-Anchor on a genome wide example you can download the **INPUT/** sample folder that contains cattle (reference) and yak (target) genomes with the Universal HCE databank which is built by using the alignments of 99 species against human (see the paper for details). The reference genome was changed from human to cattle with the G-Anchor's preprocessing pipeline .

http://www.filehosting.org/file/details/652631/INPUT.tar.gz

### Finding the outputs:

#### G-Anchor's outputs:
G-Anchor produces 4 different outputs that are in the **OUTPUT_target/** folder and a logfile :
* **OUTPUT_target/**
     * **chains_target/:** The alignments in _.chain_ format
     * **nets_target/:** The alignments in _.net_ format
     * **psl_final_target:/** The alignments in _.psl_ format
     * **chromosomes_blueprint.txt:** A list with the number of HCE anchors on each target scaffold ("v" indicator shows that there are more than one elements that a mapped scaffold partially in a different chromosome with more than one HCE. "p" indicator shows that the partially mapped scaffold is supported only by one HCE).
* **logFile_target:** A log file that you can truck if an error was occured in a pipeline's step.

#### G-Anchors preprocessing outputs:
* **FINAL_coords/:** The coordinates of the HCE in _.bed_ format, based on the new reference genome.
* **FINAL_FASTA/:** The sequences of the HCE in _.fasta_ format based on the new reference genome, ready to be used by G-Anchor.

More details about the outputs or about G-Anchor in general, you can find in:
 
 /*give the url of the paper*/

### Notes
*  In order to run G-Anchor without any issues you should be careful to have your data in the appropriate format and to put them on the right subfolders in the INPUT folder (reference genome ---> INPUT/GENOMES_DB/REFERENCE/, target genome ---> INPUT/GENOMES_DB/TARGET/, HCE sequences (fasta) ---> INPUT/HCEs_DB/, HCE coordinates (bed) ---> INPUT/HCEs_coords/). To understand the structure, run the sample dataset first.
* _**--fastMap**_ parameter can reduce significantly the running time of the mapping phase but it can reduce the sensitivity, too. It also can work only with HCE that are smaller than 5kbp. G-Anchor splits the HCE that are larger than 5 kbp by default when fastMap option is enabled (For more information take a look at BLAT publication: "BLAT: The BLAST-like alignment tool, Kent WJ, 2002").
* **_--fastMap_ parameter on the preprocessing stage:** Using fastMap flag on the preprocessing stage the HCE databank preparation will be faster but some HCE might be lost. As a result, G-Anchor could map less scaffolds in number. 
