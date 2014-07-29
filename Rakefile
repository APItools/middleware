require 'bundler/setup'
require 'apitools-middleware'

task default: :test

task :test do
  repository = Apitools::Middleware::LocalRepository.new
  middleware = repository.middleware

  puts "Found #{middleware.size} middlewares."

  _valid, invalid = middleware.partition(&:valid?)

  invalid.each do |middleware|
    warn "#{middleware.path} is not valid"
  end

  if invalid.any?
    puts "[FAIL] #{invalid.size} middleware are invalid"
    exit(false)
  end

  puts '[SUCCESS] all middlewares are ok'
end
