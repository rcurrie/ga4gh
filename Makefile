# GA4GH_VERSION := e11023f830d1
GA4GH_VERSION := latest

clean:
	rm -rf data
	mkdir -p data

download:
	# Download HG38 Reference and TARGET dataset from Xena as test case
	wget -N -P data https://toil.xenahubs.net/download/target_RSEM_gene_tpm
	wget -N -P data "ftp://ftp.ncbi.nlm.nih.gov/genomes/archive/old_genbank/Eukaryotes/vertebrates_mammals/Homo_sapiens/GRCh38/seqs_for_alignment_pipelines/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz"
	gunzip data/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz
	bgzip data/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna

init:
	# Create a new repo and dataset
	docker run -it --rm -v `pwd`/data:/data ga4gh/server:$(GA4GH_VERSION) \
		ga4gh_repo init --force /data/repo.db
	docker run -it --rm -v `pwd`/data:/data ga4gh/server:$(GA4GH_VERSION) \
		ga4gh_repo add-dataset /data/repo.db TARGET --description "TARGET Pan-Cancer Compendium"

list:
	# List all the objects in the server
	docker run -it --rm -v `pwd`/data:/data ga4gh/server:$(GA4GH_VERSION) \
		ga4gh_repo list /data/repo.db

reference:
	# Add the genome reference to the server
	docker run -it --rm -v `pwd`/data:/data ga4gh/server:$(GA4GH_VERSION) \
		ga4gh_repo add-referenceset /data/repo.db \
		/data/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz \
		-d "HG38 Assembly of the Human Genome" --name hg38 \
		--sourceUri "ftp://ftp.ncbi.nlm.nih.gov/genomes/archive/old_genbank/Eukaryotes/vertebrates_mammals/Homo_sapiens/GRCh38/seqs_for_alignment_pipelines/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz"

populate:
	rm -f data/rnaseq.db
	docker run -it --rm -v `pwd`/data:/data ga4gh/server:$(GA4GH_VERSION) \
		ga4gh_repo init-rnaquantificationset /data/repo.db /data/rnaseq.db
	docker run -it --rm -v `pwd`/data:/data ga4gh/server:$(GA4GH_VERSION) \
		ga4gh_repo add-rnaquantification /data/rnaseq.db /data/rsem.genes.norm_counts.hugo.tab \
		rsem /data/repo.db TARGET --biosampleName "TEST"

install:
	docker run -it --rm -v `pwd`/data:/data ga4gh/server:$(GA4GH_VERSION) \
		ga4gh_repo add-rnaquantificationset /data/repo.db TARGET /data/rnaseq.db -n TARGET -R hg38

uninstall:
	docker run -it --rm -v /data/ga4gh:/data -v /data/treehouse:/treehouse:ro ga4gh/server:$(GA4GH_VERSION) \
		ga4gh_repo remove-rnaquantificationset /data/repo.db TreehouseV2

run_server:
	docker run -it --rm --name ga4gh \
		-e GA4GH_DEBUG=True \
		-e GA4GH_DATA_SOURCE=/data \
		-v /data/ga4gh:/data:ro \
		-p 5000:80 \
		ga4gh/server python server_dev.py --host 0.0.0.0 

stop:
	docker stop ga4gh || true && docker rm ga4gh || true
