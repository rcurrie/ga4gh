init:
	rm /data/ga4gh/repo.db
	docker run -it --rm -v /data/ga4gh:/data ga4gh/server:latest \
		ga4gh_repo init /data/repo.db
	docker run -it --rm -v /data/ga4gh:/data ga4gh/server:latest \
		ga4gh_repo add-dataset /data/repo.db treehouse --description "Treehouse Reference Cohort v2"

reference:
	docker run -it --rm -v /data/ga4gh:/data -v /data/treehouse:/treehouse ga4gh/server:latest \
		ga4gh_repo add-referenceset /data/repo.db \
		/treehouse/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz \
		-d "HG38 assembly of the human genome" --name hg38 \
		--sourceUri "ftp://ftp.ncbi.nlm.nih.gov/genomes/archive/old_genbank/Eukaryotes/vertebrates_mammals/Homo_sapiens/GRCh38/seqs_for_alignment_pipelines/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz"

populate:
	rm -f /data/ga4gh/rnaseq.db
	docker run -it --rm -v /data/ga4gh:/data -v /data/treehouse:/treehouse:ro ga4gh/server:latest \
		ga4gh_repo init-rnaquantificationset /data/repo.db /data/rnaseq.db
	docker run -it --rm -v /data/ga4gh:/data -v /data/treehouse:/treehouse:ro ga4gh/server:latest \
		ga4gh_repo add-rnaquantification /data/rnaseq.db /treehouse/TH03_0010_S02_RNASeq/RSEM/rsem_genes.results \
		rsem /data/repo.db treehouse -n "TH03_0010_S02"

install:
	docker run -it --rm -v /data/ga4gh:/data -v /data/treehouse:/treehouse:ro ga4gh/server:latest \
		ga4gh_repo add-rnaquantificationset /data/repo.db treehouse /data/rnaseq.db -n TreehouseV2 -R hg38

uninstall:
	docker run -it --rm -v /data/ga4gh:/data -v /data/treehouse:/treehouse:ro ga4gh/server:latest \
		ga4gh_repo remove-rnaquantificationset /data/repo.db TreehouseV2

list:
	docker run -it --rm -v /data/ga4gh:/data -v /data/treehouse:/treehouse:ro ga4gh/server:latest \
		ga4gh_repo list /data/repo.db

debug:
	docker run -it --rm --name ga4gh \
		-e GA4GH_DATA_SOURCE=/data \
		-v /data/ga4gh:/data:ro \
		-v /data/treehouse:/treehouse:ro \
		ga4gh/server python server_dev.py --host 0.0.0.0 --port 5000 --config-file /data/config.py

stop:
	docker stop ga4gh || true && docker rm ga4gh || true
