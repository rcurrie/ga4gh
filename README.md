# Summary
Bulk import of rna seq data into a ga4gh server

Goal is a utility easily importa an expression and phenotype
file with multiple samples into a ga4gh server.

For example the tsv phenotype and hugo rsem files for
TARGET located here:
https://xenabrowser.net/datapages/?cohort=TARGET%20Pan-Cancer%20(PANCAN)

# Running

Download the reference:

    make download

Delete any database files in ./data
    make clean

Start a ga4gh server container
    make debug

We will now have a shell inside the container in the server's directory

Change to root to access contents of this repo mapped inside the container
    
    cd ~

Create a new registry database
    
    make init

Install the reference
    
    make reference

Initialize the registry, populate an rnaseq dataset, and install it
    
    make populate install


Run the server

    make run_server

Should be able to see contents of server from host machine via
    
    curl localhost:8000

# References

Use cases for RNA quanitification API
https://ga4gh-schemas.readthedocs.io/en/latest/api/rna_quantifications.html

Issue tracking an easy rnaseq + clinical import
https://github.com/BD2KGenomics/ga4gh-integration/issues/54

Issue discussing removing requirement for reference in rnaseq
https://github.com/ga4gh/server/issues/1528

Sample's of using the python api to access a server
https://github.com/BD2KGenomics/bioapi-examples

See test.py for some examples of this that you can run in container
by exec'ng in and then running python test.py


