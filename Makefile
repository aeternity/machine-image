console:
	./docker-run.sh

test:
	./docker-run.sh packer validate packer/aeternity.json

build:
	./docker-run.sh packer build packer/aeternity.json

clean:
	./docker-run.sh python packer/scripts/ami-cleanup.py

.PHONY: build test clean console
