PLUGIN_NAME := terraria.lua
PLUGIN_DIR ?= $(HOME)/.local/lib/wireshark/plugins
PLUGIN_PATH := $(PLUGIN_DIR)/$(PLUGIN_NAME)
RUNTIME_PLUGIN_DIR ?= /tmp/terraria-wireshark-plugins
SRC_DIR := $(CURDIR)/src
# Where the loader looks for the dissector. The default runs straight from the checkout;
# any other directory receives a copy of src/ on install.
MODULE_DIR ?= $(SRC_DIR)
LOADER_TEMPLATE := $(CURDIR)/plugin/terraria.lua.in
# Older installs linked the module tree into the plugin folder itself.
LEGACY_MODULE_PATH := $(PLUGIN_DIR)/terraria
LUA_LS_LOG_DIR := .lua-ls-log
LUA_LS_META_DIR := .lua-ls-meta

.PHONY: install uninstall path check-lua runtime-check test test-update

install:
	mkdir -p "$(PLUGIN_DIR)"
	@if [ -L "$(LEGACY_MODULE_PATH)" ]; then rm "$(LEGACY_MODULE_PATH)" && echo "Removed legacy module link: $(LEGACY_MODULE_PATH)"; fi
	@if [ "$(MODULE_DIR)" != "$(SRC_DIR)" ]; then \
		mkdir -p "$(MODULE_DIR)" && rm -rf "$(MODULE_DIR)/terraria" && \
		cp -R "$(SRC_DIR)/terraria" "$(SRC_DIR)/terraria.lua" "$(MODULE_DIR)/"; \
	fi
# rm first: an older install left a symlink here that points into src/.
	rm -f "$(PLUGIN_PATH)"
	sed 's|@MODULE_DIR@|$(MODULE_DIR)|' "$(LOADER_TEMPLATE)" >"$(PLUGIN_PATH)"
	@echo "Installed: $(PLUGIN_PATH) -> $(MODULE_DIR)"

uninstall:
	rm -f "$(PLUGIN_PATH)"
	@if [ -L "$(LEGACY_MODULE_PATH)" ]; then rm "$(LEGACY_MODULE_PATH)"; fi
	@echo "Removed: $(PLUGIN_PATH)"

path:
	@echo "$(PLUGIN_PATH)"

check-lua:
	mise exec -- lua-language-server --check="$(CURDIR)" --configpath="$(CURDIR)/.luarc.json" --checklevel=Warning --logpath="$(CURDIR)/$(LUA_LS_LOG_DIR)" --metapath="$(CURDIR)/$(LUA_LS_META_DIR)"

runtime-check:
	@test -n "$(PCAP)" || (echo "Set PCAP=/path/to/capture.pcap[ng]" && exit 1)
	$(MAKE) install PLUGIN_DIR="$(RUNTIME_PLUGIN_DIR)"
	WIRESHARK_PLUGIN_DIR="$(RUNTIME_PLUGIN_DIR)" tshark -r "$(PCAP)" -V >"/tmp/terraria-runtime-check.log" 2>&1
	@echo "Runtime log: /tmp/terraria-runtime-check.log"

test:
	tests/run.sh

test-update:
	tests/run.sh --update
