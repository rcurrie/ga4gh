# GA4GH_VERSION := e11023f830d1
GA4GH_VERSION := latest

clean:
	rm -f data/*.db
	mkdir -p data

download:
	# Download HG38 Reference and convert to bgzip
	wget -N -P data "ftp://ftp.ncbi.nlm.nih.gov/genomes/archive/old_genbank/Eukaryotes/vertebrates_mammals/Homo_sapiens/GRCh38/seqs_for_alignment_pipelines/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz"
	gunzip data/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz
	bgzip data/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna

init:
	# Create a new registry
	docker run -it --rm -v `pwd`/data:/data ga4gh/server:$(GA4GH_VERSION) \
		ga4gh_repo init --force /data/registry.db

reference:
	# Add the genome reference to the server
	docker run -it --rm -v `pwd`/data:/data ga4gh/server:$(GA4GH_VERSION) \
		ga4gh_repo add-referenceset /data/registry.db \
		/data/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz \
		-d "HG38 Assembly of the Human Genome" --name hg38 \
		--sourceUri "ftp://ftp.ncbi.nlm.nih.gov/genomes/archive/old_genbank/Eukaryotes/vertebrates_mammals/Homo_sapiens/GRCh38/seqs_for_alignment_pipelines/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz"

populate:
	rm -f data/rnaseq.db
	docker run -it --rm -v `pwd`/data:/data ga4gh/server:$(GA4GH_VERSION) \
		ga4gh_repo add-dataset /data/registry.db TEST_DATASET --description "TEST_DATASET Description"
	docker run -it --rm -v `pwd`/data:/data ga4gh/server:$(GA4GH_VERSION) \
		ga4gh_repo add-biosample /data/registry.db TEST_DATASET Patient0 '{"individualId": "Patient0ID"}'
	docker run -it --rm -v `pwd`/data:/data ga4gh/server:$(GA4GH_VERSION) \
		ga4gh_repo init-rnaquantificationset /data/registry.db /data/rnaseq.db
	cp rsem.genes.norm_counts.hugo.tab data/
	docker run -it --rm -v `pwd`/data:/data ga4gh/server:$(GA4GH_VERSION) \
		ga4gh_repo add-rnaquantification /data/rnaseq.db /data/rsem.genes.norm_counts.hugo.tab \
		rsem /data/registry.db TEST_DATASET --biosampleName "Patient0"

install:
	docker run -it --rm -v `pwd`/data:/data ga4gh/server:$(GA4GH_VERSION) \
		ga4gh_repo add-rnaquantificationset /data/registry.db TEST_DATASET /data/rnaseq.db -n TEST_DATASET -R hg38

uninstall:
	docker run -it --rm -v `pwd`/data:/data ga4gh/server:$(GA4GH_VERSION) \
		ga4gh_repo remove-dataset /data/registry.db TEST_DATASET

list:
	# List all the objects in the server
	docker run -it --rm -v `pwd`/data:/data ga4gh/server:$(GA4GH_VERSION) \
		ga4gh_repo list /data/registry.db

run_server:
	docker run -it --rm --name ga4gh \
		-e GA4GH_DEBUG=True \
		-e GA4GH_DATA_SOURCE=/data \
		-v /data/ga4gh:/data:ro \
		-p 5000:80 \
		ga4gh/server python server_dev.py --host 0.0.0.0 

stop:
	docker stop ga4gh || true && docker rm ga4gh || true
