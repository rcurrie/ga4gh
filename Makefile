init:
	rm /data/ga4gh/repo.db
	docker run -it --rm -v /data/ga4gh:/data ga4gh/server:latest \
		ga4gh_repo init /data/repo.db
	docker run -it --rm -v /data/ga4gh:/data ga4gh/server:latest \
		ga4gh_repo add-dataset /data/repo.db treehouse --description "Treehouse Reference Cohort v2"

populate:
	rm -f /data/ga4gh/rnaseq.db
	docker run -it --rm -v /data/ga4gh:/data -v /data/treehouse:/treehouse:ro ga4gh/server:latest \
		ga4gh_repo init-rnaquantificationset /data/repo.db /data/rnaseq.db
	docker run -it --rm -v /data/ga4gh:/data -v /data/treehouse:/treehouse:ro ga4gh/server:latest \
		ga4gh_repo add-rnaquantification /data/rnaseq.db /treehouse/test_rsem.tsv \
		rsem /data/repo.db treehouse

hg38:
	docker run -it --rm -v /data/ga4gh:/data -v /data/treehouse:/treehouse ga4gh/server:latest \
		ga4gh_repo add-referenceset /data/repo.db /treehouse/hg38.fa.gz \
		-d "HG38 assembly of the human genome" --name hg38

grch38:
	docker run -it --rm -v /data/ga4gh:/data -v /data/treehouse:/treehouse ga4gh/server:latest \
		ga4gh_repo add-referenceset /data/repo.db /treehouse/GRCh38.fa.gz \
		-d "GRCh38 assembly of the human genome" --name GRCh38 \
		--sourceUri "ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa"


list:
	docker run -it --rm -v /data/ga4gh:/data -v /data/treehouse:/treehouse:ro ga4gh/server:latest \
		ga4gh_repo list /data/repo.db

install:
	docker run -it --rm -v /data/ga4gh:/data -v /data/treehouse:/treehouse:ro ga4gh/server:latest \
		ga4gh_repo add-rnaquantificationset /data/repo.db treehouse /data/rnaseq.db -n v2 -R hg38

debug:
	docker run -it --rm --name ga4gh \
		-e GA4GH_DATA_SOURCE=/data \
		-v /data/ga4gh:/data:ro \
		-v /data/treehouse:/treehouse:ro \
		-p 8000:80 \
		ga4gh/server python server_dev.py --host 0.0.0.0 --port 80 --config-file /data/config.py

jupyter:
	docker run --rm -it --name jupyter \
		-p 8888:8888 \
		-v `pwd`:/home/jovyan/work \
		-v /data:/data \
		--link ga4gh:g4gh \
		jupyter

stop:
	docker stop jupyter || true && docker rm jupyter || true
	docker stop ga4gh || true && docker rm ga4gh || true

build:
	docker build -t jupyter .
