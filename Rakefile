require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) do |spec|
  # spec.spec_files = FileList['spec/**/*_spec.rb']
  spec.rspec_opts = %w[--color -Ilib -Ispec]
end

task :default => :spec