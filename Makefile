# Iron and Alms — Makefile

GO     := go
GOFMT  := gofmt
GOCMD  := $(GO)
BINARY := iron-and-alms

.PHONY: all build dev test fmt lint clean help

all: build test

build:
	$(GOCMD) build -o $(BINARY) ./...

dev:
	air

test:
	$(GOCMD) test -v  -race ./...

fmt:
	$(GOFMT) -s -w ./...

lint:
	$(GOCMD) vet ./...

clean:
	rm -f $(BINARY)

help:
	@echo "Available targets:"
	@echo "  build  - build the game binary"
	@echo "  test   - run all tests"
	@echo "  fmt    - format all Go source"
	@echo "  lint   - run go vet"
	@echo "  dev    - live reload via air (install: go install github.com/air-verse/air@latest)"
	@echo "  clean  - remove build artifacts"
	@echo "  help   - show this help"
