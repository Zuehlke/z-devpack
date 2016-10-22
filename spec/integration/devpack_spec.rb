require_relative '../helpers'

describe "NDS devpack" do

  include Helpers

  describe "tools" do
    it "installs Ruby 2.3.1" do
      run_cmd("ruby -v").should match('2.3.1')
    end
    it "installs Terraform 0.7.7" do
      run_cmd("terraform --version").should match('0.7.7')
    end
    it "installs Git 2.10.1 " do
      run_cmd("git --version").should match('git version 2.10.1.windows.1')
    end
    it "installs wget 1.18" do
      run_cmd("wget --version").should match(/^GNU Wget 1.18 built on mingw32./)
    end
    it "installs aws-cli 1.11.7" do
      run_cmd("aws --version").should match(/aws-cli\/1.11.7/)
    end
  end

  describe "environment" do
    it "sets BK_ROOT to W:/" do
      env_match "BK_ROOT=#{build_dir}/"
    end
    it "sets HOME to W:/home" do
      env_match "HOME=#{build_dir}/home"
    end
    it "sets VBOX_USER_HOME to %USERPROFILE%" do
      env_match "VBOX_USER_HOME=#{ENV['USERPROFILE']}"
    end
    it "sets SSL_CERT_FILE to W:/home/cacert.pem" do
      env_match "SSL_CERT_FILE=#{build_dir}/home/cacert.pem"
    end
  end

  describe "aliases" do
    it "aliases `bundle exec` to `be`" do
      run_cmd("doskey /macros").should match('be=bundle exec $*')
    end
    it "aliases `atom` to `vi`" do
      run_cmd("doskey /macros").should match('vi=atom.cmd $*')
    end
  end

  describe "atom installation" do
    it "installs atom 1.11.2" do
      # see https://github.com/atom/atom-shell/issues/683
      # so we 1) ensure the atom.cmd is on the PATH and 2) it's the right version      
      run_cmd("#{build_dir}/tools/atom/resources/cli/atom.cmd -v").should match("Atom    : 1.11.2\nElectron: 0.37.8\nChrome  : 49.0.2623.75\nNode    : 5.10.0\n")
    end
    it "installs apm 1.9.2" do
      run_cmd("#{build_dir}/tools/atom/resources/app/apm/bin/apm.cmd -v --no-color").should match(/^apm  1.12.5/)
    end
    describe "atom plugins" do
      it "has 'atom-beautify' plugin installed" do
        atom_plugin_installed "atom-beautify"
      end
      it "has 'minimap' plugin installed" do
        atom_plugin_installed "minimap"
      end
      it "has 'line-ending-converter' plugin installed" do
        atom_plugin_installed "line-ending-converter"
      end
      it "has 'language-chef' plugin installed" do
        atom_plugin_installed "language-chef"
      end
      it "has 'language-batchfile' plugin installed" do
        atom_plugin_installed "language-batchfile"
      end
      it "has 'autocomplete-plus' plugin installed" do
        atom_plugin_installed "autocomplete-plus"
      end
      it "has 'autocomplete-snippets' plugin installed" do
        atom_plugin_installed "autocomplete-snippets"
      end
    end
  end
end
