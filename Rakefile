%w{ bundler yaml uri net/https tmpdir digest/md5}.each do |file|
  require file
end
require "#{File.dirname(__FILE__)}/doc/markit"
require "#{File.dirname(__FILE__)}/lib/devpack"

# Immediately sync all stdout so that it's immediately visible, e.g. on appveyor
$stdout.sync = true
$stderr.sync = true
include DevPack
# use Windows builtin robocopy command to purge overly long paths,
# see https://blog.bertvanlangen.com/articles/path-too-long-use-robocopy/
def purge_atom_plugins_with_insanely_long_path
  empty_dir = "#{tools_dir}/empty"
  atom_packages_dir = "#{build_dir}/home/.atom/packages"
  if File.exist?(atom_packages_dir)
    begin
      FileUtils.rm_rf empty_dir
      FileUtils.mkdir_p empty_dir
      sh "robocopy #{empty_dir} #{atom_packages_dir} /purge > NUL"
    rescue
      retry
    end
  end
end
#Moving files around to avoid awkward directory names etc.
def fix_tools tools_config
  if tools_config.keys.include?("ruby")
    puts "Fixing Ruby"
    Rake::FileList["#{build_dir}/tools/ruby/ruby-*-mingw32"].each do |f|
      Rake::FileList["#{build_dir}/tools/ruby/#{f.pathmap("%f")}/*"].each do |m|
        mv(m,"#{build_dir}/tools/ruby",:verbose=>false)
      end
      rm_rf(f,:verbose=>true)
    end
  end
  if tools_config.keys.include?("atom")
    puts "Fixing Atom"
    Rake::FileList["#{build_dir}/tools/atom/Atom/*"].each do |f|
      mv(f,"#{build_dir}/tools/atom",:verbose=>false)
    end
    rm_rf("#{build_dir}/tools/atom/Atom",:verbose=>false)
  end
  if tools_config.keys.include?("aws-cli")
    puts "Fixing aws-cli"
    Rake::FileList["#{build_dir}/tools/aws-cli/Amazon/AWSCLI/*"].each do |f|
      mv(f,"#{build_dir}/tools/aws-cli",:verbose=>false)
    end
    rm_rf("#{build_dir}/tools/aws-cli/Amazon",:verbose=>false)
  end
end
def install_atom_plugins tool_config
  commands=["#{build_dir}/set-env.bat"]
  commands+=tool_config.fetch("plugins",{}).keys.map do |plug|
    "apm install #{plug}"
  end
  Bundler.with_clean_env do
    command = commands.join(" && ")
    fail "atom plugins installation failed" unless system(command)
  end
end
def reset_git_user
  Bundler.with_clean_env do
    command = "#{build_dir}/set-env.bat \
      && git config --global --unset user.name \
      && git config --global --unset user.email"
    fail "resetting dummy git user failed" unless system(command)
  end
end
def install_gems ruby_config
  commands = ["cd /D #{build_dir}","mount-drive.cmd","#{build_dir}/set-env.bat"]
  ruby_config.fetch("gems",{}).each do |name,ver|
    commands<<"gem install #{name} --version \"#{ver}\""
  end
  begin
    Bundler.with_clean_env do
     command = commands.join(" && ")
     fail "gem installation failed" unless system(command)
    end
  ensure
    system("cd /D #{build_dir}")
    system("unmout-drive.cmd")
  end
end

namespace :devpack do
  desc 'Clean the build output directory'
  task :clean do
    purge_atom_plugins_with_insanely_long_path
    clean_build
  end
  desc 'Wipe all output and cache directories'
  task :wipe => :clean do
    clean_cache
  end
  desc 'Download required resources and build the devpack'
  task :build  do
    create_devpack_structure
    download_tools(devpack_config)
    fix_tools(devpack_config)
    copy_files
    if has_tool?("ruby")
      install_gems(tool_config("ruby"))
    end
    generate_docs
    if has_tool?("atom")
      install_atom_plugins(tool_config("atom"))
    end
    puts "Done!"
  end
  desc 'Run integration tests'
  task :test do
    run_integration_tests
  end
  desc 'Creates the devpack .7z package'
  task :package do
    assemble("z-devpack")
  end
end
