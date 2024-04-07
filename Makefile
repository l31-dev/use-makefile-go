.PHONY: confirm help test test/cover build run run/live tidy audit push production/deploy

# Define variables
MAIN_PACKAGE_PATH:=./cmd/example
BINARY_NAME:=example

# Targets:

## help: Display this help message
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s: |  sed -e 's/^/ /'

## confirm: Prompt user for confirmation
confirm:
	@echo -n 'Are you sure? [y/N] ' && read ans && [ $${ans:-N} = y ]

## no-dirty: Check if there are no changes in git
no-dirty:
	git diff --exit-code

## tidy: Tidy go modules and format code
tidy:
	go fmt ./...
	go mod tidy -v

## audit: Verify go modules, vet code and check for static and vulnerabilities
audit:
	go mod verify
	go vet ./...
	go run honnef.co/go/tools/cmd/staticcheck@latest -checks=all,-ST1000,-U1000 ./...
	go run golang.org/x/vuln/cmd/govulncheck@latest ./...
	go test -race -buildvcs -vet=off ./...

## test: Run tests
test:
	go test -v -race -buildvcs ./...

## test/cover: Run tests with coverage
test/cover:
	go test -v -race -buildvcs -coverprofile=/tmp/coverage.out ./...
	go tool cover -html=/tmp/coverage.out

## build: Build the binary
build:
	go build -o=/tmp/bin/${BINARY_NAME} ${MAIN_PACKAGE_PATH}

## run: Build and run the binary
run: build
	/tmp/bin/${BINARY_NAME}

## run/live: Run the binary with auto-reload
run/live:
	go run github.com/cosmtrek/air@v1.43.0 \
		--build.cmd="make build" --build.bin="/tmp/bin/${BINARY_NAME}" --build.delay="100" \
		--build.exclude_dir="" \
		--build.include_ext="go,tpl,tmpl,html,css,scss,js,ts,sql,jpeg,jpg,gif,png,bmp,svg,webp,ico" \
		--misc.clean_on_exit="true"

## push: Push changes to git
push: tidy audit no-dirty
	git push


## production/deploy: Tag and create a new release on Github
production/deploy: confirm tidy audit no-dirty
	GOOS=linux GOARCH=amd64 go build -ldflags='-s' -o=/tmp/bin/linux_amd64/${BINARY_NAME} ${MAIN_PACKAGE_PATH}
	upx -o=/tmp/bin/linux_amd64/${BINARY_NAME} /tmp/bin/linux_amd64/${BINARY_NAME}

install/manjaro:
	sudo pacman -S --noconfirm go
	sudo pamac install github-cli upx

