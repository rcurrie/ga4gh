debug:
	docker run -it --rm --name ga4gh \
		-v `pwd`/data:/data \
		-v `pwd`:/root \
		-p 5000:8000 \
		ga4gh/server python server_dev.py --host 0.0.0.0 --config-file /root/config.py

shell:
	docker exec -it ga4gh /bin/bash

download:
	# Download HG38 Reference and convert to bgzip
	wget -N -P data "ftp://ftp.ncbi.nlm.nih.gov/genomes/archive/old_genbank/Eukaryotes/vertebrates_mammals/Homo_sapiens/GRCh38/seqs_for_alignment_pipelines/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz"
	gunzip data/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz
	bgzip data/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna

init:
	# Create a new registry
	ga4gh_repo init --force /data/registry.db

reference:
	# Add the genome reference to the server
	ga4gh_repo add-referenceset /data/registry.db \
		/data/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz \
		-d "HG38 Assembly of the Human Genome" --name hg38 \
		--sourceUri "ftp://ftp.ncbi.nlm.nih.gov/genomes/archive/old_genbank/Eukaryotes/vertebrates_mammals/Homo_sapiens/GRCh38/seqs_for_alignment_pipelines/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz"

populate:
	# Create a dataset and add a biosample and quantification set
	rm -f /data/rnaseq.db
	ga4gh_repo add-dataset /data/registry.db TEST_DATASET --description "TEST_DATASET Description"
	ga4gh_repo add-individual /data/registry.db TEST_DATASET Individual0 \
		'{"description": "Individual0 Description"}'
	ga4gh_repo add-biosample /data/registry.db TEST_DATASET Biosample0 '{"individualId": "Individual0"}'
	ga4gh_repo init-rnaquantificationset /data/registry.db /data/rnaseq.db
	cp rsem.genes.norm_counts.hugo.tab /data/
	ga4gh_repo add-rnaquantification /data/rnaseq.db /data/rsem.genes.norm_counts.hugo.tab \
		rsem /data/registry.db TEST_DATASET --biosampleName "Biosample0"

install:
	# Install the datset in the server
	ga4gh_repo add-rnaquantificationset /data/registry.db TEST_DATASET /data/rnaseq.db -n TEST_DATASET -R hg38

uninstall:
	# Unintall the dataset in the server
	ga4gh_repo remove-dataset /data/registry.db TEST_DATASET

list:
	# List all the objects in the server
	ga4gh_repo list /data/registry.db


stop:
	docker stop ga4gh || true && docker rm ga4gh || true
