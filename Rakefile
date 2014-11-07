require 'apitools-middleware'
require 'highline/import'
require 'active_support/core_ext/string/inflections'
require 'i18n'
require 'json'
require 'erb'

I18n.enforce_available_locales = true

task default: :test

task :test do
  repository = Apitools::Middleware::LocalRepository.new
  middleware = repository.middleware

  puts "Found #{middleware.size} middlewares."

  _valid, invalid = middleware.partition(&:valid?)

  invalid.each do |mw|
    warn "#{mw.path} is not valid"
  end

  if invalid.any?
    puts "[FAIL] #{invalid.size} middleware are invalid"
    exit(false)
  end

  puts '[SUCCESS] all middlewares are ok'
end


MIDDLEWARE_TEMPLATE = <<-TEMPLATE
--[[
--
-- This middleware ...
--
--]]

return function(request, next_middleware)
  return next_middleware()
end
TEMPLATE

README_TEMPLATE = <<-TEMPLATE
# Middleware ...

Usage ...

## Requirements
* another middleware
TEMPLATE

SPEC_TEMPLATE = <<-TEMPLATE
local spec = require 'spec.spec'

describe('<%= name %>', function()
  local <%= param %>
  before_each(function()
    <%= param %> = spec.middleware('<%= [folder, file].join('/') %>')
  end)

  it('it calls and returns next middleware', function()
    local request         = spec.request({method = 'GET', uri = '/'})
    local next_middleware = spec.next_middleware(function()
      assert.contains(request, {method = 'GET', uri = '/'})
      return {status = 200, body = 'ok'}
    end)

    local response = <%= param %>(request, next_middleware)

    assert.spy(next_middleware).was_called()

    assert.contains(response, {status = 200, body = 'ok'})
  end)
end)
TEMPLATE

def render(template, binding)
  ERB.new(template).result(binding)
end

desc 'New Middleware Wizard'
task :middleware do
  comma_separated = ->(str) { str.split(/,\s*/).map(&:strip) }
  spec = {
    name: name = ask('Middleware Name: ', String) {|q| q.validate = /./ },
    description: ask('Description: ', String) {|q| q.validate = /./ },
    files: [file = ask('File Name: ', String) {|q| q.default = name.parameterize('_') + '.lua'; q.validate = /^\S+\.\S+$/ }],
    spec: [Pathname(file).sub_ext('_spec.lua').to_s],
    author: ask('Author: ', String) {|q| q.default = `git config --get user.name`.strip },
    email: ask('Email: ', String) {|q| q.validate = /@/; q.default = `git config --get user.email`.strip },
    version: ask('Version: ', String) {|q| q.default = '1.0.0'; q.validate = /^\d\.\d/ },
    categories: ask('Categories: ', comma_separated),
    endpoints: ask('Endpoints: ', comma_separated) {|q| q.default = '*' },
  }
  folder = ask('Folder: ', String) { |q| q.default = name.parameterize('-'); q.validate = /./ }

  path = Pathname('middleware').join(folder)

  path.exist? and raise "#{folder} already exists"

  json = path.join('apitools.json')
  json.exist? and raise "apitools.json already exists"

  lua = path.join(file)
  lua.exist? and raise "#{file} already exists"

  readme = path.join('README.md')
  readme.exist? and raise "#{readme} already exists"

  test = lua.sub_ext('_spec.lua')
  test.exist? and raise "#{test} already exists"

  name = spec.fetch(:name)
  param = lua.basename(lua.extname).to_s.parameterize('_')

  path.mkdir
  puts "Created #{path}"
  json.write(JSON.pretty_generate(spec))
  puts "Created #{json}"
  lua.write(render(MIDDLEWARE_TEMPLATE, binding))
  puts "Created #{lua}"
  readme.write(render(README_TEMPLATE, binding))
  puts "Created #{readme}"
  test.write(render(SPEC_TEMPLATE, binding))
  puts "Created #{test}"
end
