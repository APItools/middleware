DEPENDENCIES = luacheck busted lua-cjson luasocket luaexpat

all_lua_files     = $(wildcard middleware/**/*.lua)
source_files      = $(filter-out %_spec.lua, $(all_lua_files))
specs             = $(wildcard middleware/**/*_spec.lua)
pipeline_globals  = console inspect log base64 hmac http bucket send time metric trace json xml
MIDDLEWARE = $(patsubst middleware/%,%,$(wildcard middleware/*))
INSTALLED = $(foreach dep,$(DEPENDENCIES),$(findstring $(dep),$(shell luarocks list $(dep) --porcelain)))
MISSING = $(filter-out $(INSTALLED), $(DEPENDENCIES))

.PHONY: all test check_specs check_sources middleware
.DEFAULT_GOAL: all

all: check test
check: check_sources check_specs

test:
	busted -v middleware
	@echo

check_sources:
	luacheck -q -a $(source_files) --globals - $(pipeline_globals)
	@echo

check_specs:
	luacheck -q -a $(specs) --globals - describe it pending before_each $(pipeline_globals)
	@echo

middleware: $(MIDDLEWARE)
$(MIDDLEWARE): % :
	busted -v middleware/$@

$(INSTALLED) : % :
	@echo $@ already installed
$(MISSING) : % :
	luarocks install $@

dependencies: $(DEPENDENCIES)
