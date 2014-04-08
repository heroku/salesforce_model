Gem::Specification.new do |s|
  s.name               = "salesforce_model"
  s.version            = "0.0.2"
  s.licenses           = ['MIT']

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Scott Persinger"]
  s.date = %q{2014-04-08}
  s.description = %q{Base ActiveRecord subclass for accessing Heroku Connect sync tables}
  s.email = %q{scottp@heroku.com}
  s.files = ["lib/salesforce_model.rb"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = "AR subclass for accessing Heroku Connect tables"
  s.homepage = "https://github.com/heroku/salesforce_model"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
