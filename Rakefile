require 'bundler/setup'
require 'apitools-middleware'
require 'highline/import'
require 'active_support/core_ext/string/inflections'
require 'etc'
require 'i18n'
require 'json'

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

desc 'New Middleware Wizard'
task :middleware do
  comma_separated = ->(str) { str.split(/,\s*/).map(&:strip) }
  spec = {
    name: name = ask('Middleware Name: ', String) {|q| q.validate = /./ },
    description:  ask('Description: ', String) {|q| q.validate = /./ },
    files: [file = ask('File Name: ', String) {|q| q.default = name.parameterize('_') + '.lua' }],
    author: ask('Author: ', String) {|q| q.default = Etc.getlogin },
    email: ask('Email: ', String) {|q| q.validate = /@/; q.default = `git config --get user.email`.strip },
    version: ask('Version: ', String) {|q| q.default = '1.0.0'; q.validate = /^\d\.\d/ },
    categories: ask('Categories: ', comma_separated),
    endpoints: ask('Endpoints: ', comma_separated){|q| q.default = '*' },
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

  path.mkdir
  puts "Created #{path}"
  json.write(JSON.pretty_generate(spec))
  puts "Created #{json}"
  lua.write(MIDDLEWARE_TEMPLATE)
  puts "Created #{lua}"
  readme.write(README_TEMPLATE)
  puts "Created #{readme}"
end
