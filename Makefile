all_lua_files     = $(wildcard middleware/**/*.lua)
source_files      = $(filter-out %_spec.lua, $(all_lua_files))
specs             = $(wildcard middleware/**/*_spec.lua)
pipeline_globals  = console inspect log base64 hmac http bucket send time metric trace json xml

.PHONY: all test check_specs check_sources

test:
	busted -v middleware
check_sources:
	luacheck -q -a $(source_files) --globals - $(pipeline_globals)
check_specs:
	luacheck -q -a $(specs) --globals - describe it pending $(pipeline_globals)
all: test check_sources check_specs


