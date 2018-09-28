console:
	./docker-run.sh

test:
	./docker-run.sh packer validate packer/epoch.json

build:
	./docker-run.sh packer/scripts/dump-gcp-credentials.sh; packer build packer/epoch.json

clean:
	./docker-run.sh python packer/scripts/ami-cleanup.py

.PHONY: build test clean console
