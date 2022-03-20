test:
	go test ./...

build:
	go build \
	  -race \
	  -ldflags "-X git.qikqiak.com/${CI_PROJECT_PATH}/vendor/github.com/prometheus/common/version.Version=$(shell cat VERSION) \
	  -X git.qikqiak.com/${CI_PROJECT_PATH}/vendor/github.com/prometheus/common/version.Revision=${CI_COMMIT_SHA} \
	  -X git.qikqiak.com/${CI_PROJECT_PATH}/vendor/github.com/prometheus/common/version.Branch=${CI_COMMIT_REF_NAME} \
	  -X git.qikqiak.com/${CI_PROJECT_PATH}/vendor/github.com/prometheus/common/version.BuildUser=$(shell whoami)@$(shell hostname) \
	  -X git.qikqiak.com/${CI_PROJECT_PATH}/vendor/github.com/prometheus/common/version.BuildDate=$(shell date +%Y%m%d-%H:%M:%S) \
	  -extldflags '-static'" \
	  -o app

.PHONY: test build
