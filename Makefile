HOME_TARGET ?= $(HOME)
OS_TARGET ?= /etc/nixos

decrypt:
	find . \
	  -name '*.secret.gpg' \
	  -exec bash -c 'gpg --output $${1%%.gpg} --decrypt "$$1"' -- {} \;

install-home:
	stow -t $(HOME_TARGET) home

install-os:
	sudo rsync \
	  --recursive \
	  --links \
	  --safe-links \
	  --chmod=F600,D700 \
	  nixos/ \
	  $(OS_TARGET)

install: install-home install-os

.PHONY: install install-home install-os
