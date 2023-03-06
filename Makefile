HOME_TARGET ?= $(HOME)
OS_TARGET ?= /etc/nixos

decrypt:
	find . \
	  -name '*.secret.gpg' \
	  -exec bash -c 'gpg --output $${1%%.gpg} --decrypt "$$1"' -- {} \; \
	  || : # sometimes we don't have the key, and that's okay

install-home:
	mkdir -p current/home
	rsync \
	  --recursive \
	  --links \
	  --safe-links \
	  $$([ -d "$$(hostname)/home" ] && echo "$$(hostname)/home/") \
	  default/home/ \
	  current/home/
	cd current && stow -t $(HOME_TARGET) home

install-os:
	sudo rsync \
	  --recursive \
	  --links \
	  --safe-links \
	  --chmod=F600,D700 \
	  $$([ -d "$$(hostname)/nixos" ] && echo "$$(hostname)/nixos" || :) \
	  default/nixos/ \
	  $(OS_TARGET)

setup:
	nix-channel --add https://nixos.org/channels/nixpkgs-unstable
	nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
	nix-channel --add https://github.com/oxalica/rust-overlay/archive/master.tar.gz rust-overlay
	nix-channel --update
	nix-shell '<home-manager>' -A install

install: install-home install-os

.PHONY: setup decrypt install-home install-os install
