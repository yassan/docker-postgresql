NAME         := postgresql
REVISION     := $(shell git rev-parse --short HEAD)
ORIGIN       := $(shell git remote get-url origin)
# スペース区切りで複数タグ付けられる
TAGS         := $(REVISION)
RELEASE_TAGS := 10-pgadmin4
NAMESPACE    := yassan

.PHONY: build
build:
# "-t $(NAMESPACE)/$(NAME):" をprefixにして、"$(TAGS)"が複数あれば複数タグ付け
	docker build \
		--build-arg GIT_REVISION=$(REVISION) \
		--build-arg GIT_ORIGIN=$(ORIGIN) \
		--build-arg IMAGR_NAME=$(NAMESPACE)/$(NAME) \
		$(addprefix -t $(NAMESPACE)/$(NAME):,$(TAGS)) .

.PHONY: push
	@for TAG in $(TAGS); do\
		docker push $(NAMESPACE)/$(NAME):$$TAG; \
	done

.PHONY: release
release:
	@make build TAGS="$(RELEASE_TAGS)"
	@make push TAGS="$(RELEASE_TAGS)"
