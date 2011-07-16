namespace :cucumber do

  desc "Build cucumber.yml file"
  task :yml do
    steps = FileList["features/step_definitions/**.rb"].collect { |path|
      "--require #{path}"
    }.join(" ")

    File.open('cucumber.yml', 'w') { |f|
      f.write "default: \"--format pretty --require features/support/env.rb #{steps}\"\n"
    }
  end

end