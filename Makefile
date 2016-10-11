test:
	@crystal spec

build: build/darwin build/linux

build/darwin:
	@script/build_darwin

build/linux:
	@script/build_linux

clean:
	@rm dip-*
