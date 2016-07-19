M_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
Z_DIR := $(M_DIR)/zephyr
Z_VER := 1.4.0
ZSDK_VER := 0.8.1

help:
	@echo "Install dependencies: sudo make install-dep"
	@echo "Set up the build env: make setup"
	@echo "Compile only: make compile"
	@echo "Compile and upload: make upload"

check-root:
	@if [ `whoami` != root ]; then echo "Please run as sudoer/root" ; exit 1 ; fi

install-dep: check-root
	apt-get update
	apt-get install -y git make gcc gcc-multilib g++ libc6-dev-i386 g++-multilib python3-ply

setup:
	@echo "Downloading Zephyr"
	curl -sL http://bit.ly/1Y6G8d2 | tar xz
	@mv zephyr-v$(Z_VER) zephyr
	@echo "Downloading Zephyr SDK"
	curl -OL https://nexus.zephyrproject.org/content/repositories/releases/org/zephyrproject/zephyr-sdk/$(ZSDK_VER)-i686/zephyr-sdk-$(ZSDK_VER)-i686-setup.run
	chmod 755 zephyr-sdk-$(ZSDK_VER)-i686-setup.run
	@echo "Installing Zephyr SDK"
	{ echo "~/zephyr-sdk"; } | ./zephyr-sdk-$(ZSDK_VER)-i686-setup.run --nox11
	@echo "Setting options in ~/.zehyrrc"
	@echo "export ZEPHYR_GCC_VARIANT=zephyr" > ~/.zephyrrc
	@echo "export ZEPHYR_SDK_INSTALL_DIR=~/zephyr-sdk" >> ~/.zephyrrc

check-source:
	@echo "Make sure zephyr-env.sh is sourced"

compile: check-source
	-mkdir out
	@echo Compiling x86 core
	make O=$(M_DIR)/out/x86 -C $(Z_DIR)/samples/hello_world/microkernel
	@echo Compiling ARC core
	make O=$(M_DIR)/out/ARC -C $(Z_DIR)/samples/hello_world/nanokernel

upload:
	@echo Uploading compiled binaries

clean:
	rm -rf out

.PHONY: help check-root install-dep setup setup-build-env compile upload clean
