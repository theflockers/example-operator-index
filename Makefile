
VERSION ?= "latest"
INDEX_IMAGE = "quay.io/joelanford/example-operator-index:$(VERSION)"

catalog: bin/opm veneer.yaml convert.sh
	rm -rf catalog && mkdir catalog && ./convert.sh veneer.yaml > catalog/catalog.yaml

.PHONY: sanity
sanity: catalog bin/opm
	bin/opm validate catalog

.PHONY: build
build: catalog sanity bin/opm
	bin/opm alpha generate dockerfile catalog
	docker build -t $(INDEX_IMAGE) -f catalog.Dockerfile .
	rm catalog.Dockerfile

.PHONY: push
push: build
	docker push $(INDEX_IMAGE)

.PHONY: clean
clean:
	rm -r catalog

TAG ?= "0.0.0"
.PHONY: release
release: catalog
	./release.sh example-operator-index $(TAG)

OS=$(shell uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(shell uname -m | sed 's/x86_64/amd64/')
OPM_VERSION=v1.19.5
bin/opm:
	mkdir -p bin
	curl -sLO https://github.com/operator-framework/operator-registry/releases/download/$(OPM_VERSION)/$(OS)-$(ARCH)-opm && chmod +x $(OS)-$(ARCH)-opm && mv $(OS)-$(ARCH)-opm bin/opm
