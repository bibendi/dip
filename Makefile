test:
	@crystal spec

build: build/darwin build/linux

build/darwin:
	@script/build_darwin

build/linux:
	@script/build_linux

clean:
	@rm -f dip-* shard.lock
	@rm -rf .shards libs
