Gem::Specification.new do |s|
  s.name = %q{decor}
  s.version = "0.1.0"
  
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matt Todd"]
  s.date = %q{2010-12-13}
  s.description = %q{Provides a simple way to define multiple representations of an object}
  s.email = %q{chiology@gmail.com}
  s.files = [
    "decor.gemspec",
    "Gemfile",
    "Gemfile.lock",
    "Rakefile",
    "Readme.textile",
    "lib/decor.rb",
    "spec/decor_spec.rb",
    "spec/models/bare.rb",
    "spec/models/resource.rb",
    "spec/models/company.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://empl.us/decor/}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Defines multiple representations of objects}
  s.test_files = [
    "spec/spec_helper.rb",
    "spec/decor_spec.rb",
    "spec/models/bare.rb",
    "spec/models/resource.rb",
    "spec/models/company.rb"
  ]
  
  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3
    
    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency("bundler",     ["~> 1.0.0"])
      s.add_development_dependency("rake",        ["~> 0.8.7"])
      s.add_development_dependency("rspec",       ["= 2.1.0"])
      s.add_development_dependency("activemodel", ["~> 3.0.0"])
    else
      s.add_dependency("bundler",     ["~> 1.0.0"])
      s.add_dependency("rake",        ["~> 0.8.7"])
      s.add_dependency("rspec",       ["= 2.1.0"])
      s.add_dependency("activemodel", ["~> 3.0.0"])
    end
  else
    s.add_dependency("bundler",     ["~> 1.0.0"])
    s.add_dependency("rake",        ["~> 0.8.7"])
    s.add_dependency("rspec",       ["= 2.1.0"])
    s.add_dependency("activemodel", ["~> 3.0.0"])
  end
end
