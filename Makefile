all_lua_files     = $(wildcard middleware/**/*.lua)
source_files      = $(filter-out %_spec.lua, $(all_lua_files))
specs             = $(wildcard middleware/**/*_spec.lua)
pipeline_globals  = console inspect log base64 hmac http bucket send time metric trace json xml
MIDDLEWARE = $(patsubst middleware/%,%,$(wildcard middleware/*))

LUA_BINARIES := lua5.1 lua-5.1 luajit lua
LUA := $(firstword $(foreach bin,$(LUA_BINARIES),$(shell which $(bin))))
LUAROCKS := $(shell which luarocks)
LUAROCKS_VERSION := $(shell $(LUAROCKS) 2> /dev/null | grep -o 'LuaRocks [0-9]\.[0-9]\.[0-9]')

PATH := $(HOME)/.luarocks/bin:$(PATH)

ifneq (,$(LUA))
# Because Lua 5.1 outputs the version to stderr, where Luajit to stdout
LUA_VERSION := $(shell $(LUA) -v 2>&1 | awk '{ print $$1, $$2}')
endif

.PHONY: all test check_specs check_sources middleware dependencies install apitools
.DEFAULT_GOAL: all

all: check test apitools
check: check_sources check_specs

luarocks: lua
ifeq (,$(LUAROCKS))
	@echo No luarocks found
	exit 1
endif
	@echo $(LUAROCKS_VERSION)
ifeq (,$(findstring 2.2,$(LUAROCKS_VERSION)))
	@echo "Need LuaRocks 2.2)"
	exit 1
endif

lua:
ifndef LUA_VERSION
	@echo No Lua found.
	exit 1
endif
ifneq (,$(findstring LuaJIT,$(LUA_VERSION)))
	@echo Found Lua binary: $(LUA)
	@echo Version: $(LUA_VERSION)
	@echo
LUA_FOUND=1
endif
ifneq (,$(findstring 5.1,$(LUA_VERSION)))
	@echo Found Lua binary: $(LUA)
	@echo Version: $(LUA_VERSION)
	@echo
LUA_FOUND=1
endif
ifndef LUA_FOUND
	@echo $(LUA) is not supported version
	exit 1
endif

test: busted
	busted -v middleware
	@echo

check_sources: luacheck
	luacheck -q -a $(source_files) --globals - $(pipeline_globals)
	@echo

check_specs: luacheck
	luacheck -q -a $(specs) --globals - describe it pending before_each $(pipeline_globals)
	@echo

apitools:
	bundle exec rake test
	@echo

vagrant:
	vagrant up
	vagrant ssh -c 'cd /vagrant && make'
	- vagrant halt

middleware: $(MIDDLEWARE)
$(MIDDLEWARE): % :
	busted -v middleware/$@

luacheck: install
busted: install

install: luarocks
	luarocks make --local

dependencies: ECHO := 1
dependencies: install
