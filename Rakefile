begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = "--pattern specs/*rb"
  end

rescue LoadError
end

task :default => :spec
