PKGNAME := rhc_cloud_connector_worker

ifeq ($(origin VERSION), undefined)
	VERSION := 0.0.1
endif

.PHONY: build
build:
	mkdir -p _build
	CGO_ENABLED=0 go build -o _build/rhc-cloud-connector-worker cmd/rhc-cloud-connector-worker/main.go

clean:
	rm -rf _build

distribution-tarball:
	go mod vendor
	tar --create \
		--gzip \
		--file /tmp/$(PKGNAME)-$(VERSION).tar.gz \
		--exclude=.git \
		--exclude=.vscode \
		--exclude=.github \
		--exclude=.gitignore \
		--exclude=.copr \
		--transform s/^\./$(PKGNAME)-$(VERSION)/ \
		. && mv /tmp/$(PKGNAME)-$(VERSION).tar.gz .
	rm -rf ./vendor
