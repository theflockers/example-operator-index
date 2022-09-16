
OPERATOR_NAME = testoperator
OPERATOR_CATALOG_DIR = catalog/$(OPERATOR_NAME)
OPERATOR_CATALOG_CONTRIBUTION = $(OPERATOR_CATALOG_DIR)/catalog.yaml
YQ = bin/yq


# the catalog contribution target will enforce that the user selected an FBC build approach and generated the catalog
$(OPERATOR_CATALOG_CONTRIBUTION):
	@echo "$(OPERATOR_CATALOG_CONTRIBUTION) does not exist"; \
         echo ">>> you must first customize and execute 'make catalog' to generate the catalog contribution"; \
         false;

.PHONY: catalog
# replace this stub with one customized to serve your needs ... some examples below
catalog: $(OPERATOR_CATALOG_CONTRIBUTION)

# in order to have a deliverable target, the CI workflow executes the target "catalog" and wraps the resulting catalog contribution in
# a PR to the modeled catalog repo
#
# here are a few examples of different approaches to fulfilling this target
# comment out / customize the one that makes the most sense, or use them as examples in defining your own
#
# --- BASIC VENEER ---
#catalog: basic framework
#
# --- SEMVER VENEER ---
#catalog: semver framework
#
#  --- COMPOUND VENEER ---
#  this case is for when a single veneer cannot support the use-case, and automated changes to the generated FBC need to be made before it is complete
#  this example models the need to set the v0.2.1 of the operator with the `olm.deprecated` property, to prevent installation
#
#catalog: $(YQ) semver framework
#	$(YQ) eval 'select(.name == "testoperator.v0.2.1" and .schema == "olm.bundle").properties += [{"type" : "olm.deprecated", "value" : "true"}]' -i  $(OPERATOR_CATALOG_CONTRIBUTION)

# framework target provides two pieces that are helpful for any veneer approach:  
#  - an OWNERS file to provide default contribution control
#  - an .indexignore file to illustrate how to add content to the FBC contribution which should be 
#    excluded from validation via `opm validate`
.PHONY: framework
framework: CATALOG_OWNERS
	cp CATALOG_OWNERS $(OPERATOR_CATALOG_DIR)/OWNERS && \
         echo "OWNERS" > $(OPERATOR_CATALOG_DIR)/.indexignore


# basic target provides an example FBC generation from a `basic` veneer type.  
# this example takes a single file as input and generates a well-formed FBC operator contribution as an output
# the 'validate' target should be used next to validate the output
.PHONY: basic
basic: bin/opm basic-veneer.yaml clean
	mkdir -p $(OPERATOR_CATALOG_DIR) && bin/opm alpha render-veneer basic -o yaml basic-veneer.yaml > $(OPERATOR_CATALOG_CONTRIBUTION)


# semver target provides an example FBC generation from a `semver` veneer type.  
# this example takes a single file as input and generates a well-formed FBC operator contribution as an output
# the 'validate' target should be used next to validate the output
.PHONY: semver
semver: bin/opm semver-veneer.yaml clean
	mkdir -p $(OPERATOR_CATALOG_DIR) && bin/opm alpha render-veneer semver -o yaml semver-veneer.yaml > $(OPERATOR_CATALOG_CONTRIBUTION)


# validate target illustrates FBC validation
# all FBC must pass opm validation in order to be able to be used in a catalog
.PHONY: validate
validate: bin/opm $(OPERATOR_CATALOG_CONTRIBUTION) preverify
	bin/opm validate catalog && echo "catalog validation passed" || echo "catalog validation failed"


# preverify target ensures that the operator name is consistent between the destination directory and the generated catalog
# since the veneer will be modified outside the build process but needs to be consistent with the directory name
.PHONY: preverify
preverify: $(YQ) $(OPERATOR_CATALOG_CONTRIBUTION)
	./validate.sh -n $(OPERATOR_NAME) -f $(OPERATOR_CATALOG_CONTRIBUTION)


.PHONY: clean
clean:
	rm -rf catalog


OS=$(shell uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(shell uname -m | sed 's/x86_64/amd64/')
OPM_VERSION ?= v1.26.1
bin/opm:
	mkdir -p bin
	curl -sLO https://github.com/operator-framework/operator-registry/releases/download/$(OPM_VERSION)/$(OS)-$(ARCH)-opm && chmod +x $(OS)-$(ARCH)-opm && mv $(OS)-$(ARCH)-opm bin/opm


YQ_VERSION=v4.22.1
YQ_BINARY=yq_$(OS)_$(ARCH)
$(YQ):
	if [ ! -e bin ] ; then mkdir -p bin; fi
	wget  https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY} -O bin/${YQ_BINARY} && mv -f bin/${YQ_BINARY} $(YQ) && chmod +x $(YQ)

