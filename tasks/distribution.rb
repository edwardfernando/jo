Jeweler::Tasks.new do |gem|
  gem.name        = "jo"
  gem.summary     = "ActiveRecord/Rails Jo library"
  gem.description = "A concise and easy-to-use Ruby library to put json data into SQL column."
  gem.author      = "Phung Le Son"
  gem.email       = "leson.phung@gmail.com"
  gem.homepage    = "http://twitter.com/phungleson"

  gem.files       = FileList[
    'lib/*.rb',
    'lib/jo/*.rb',
    'lib/jo/validations/*.rb',
    'tasks/*.rb',
  ]
end
