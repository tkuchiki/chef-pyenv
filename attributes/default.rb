default[:pyenv] = {
  :action            => :sync,
  :install_path      => "/usr/local/pyenv",
  :repo_uri          => "https://github.com/yyuu/pyenv",
  :revision          => "master",
  :depth             => nil,
  :destination       => nil,
  :enable_checkout   => nil,
  :enable_submodule  => nil,
  :user              => nil,
  :group             => nil,
  :provider          => nil,
  :remote            => nil,
  :ssh_wrapper       => nil,
  :timeout           => nil,
  :python_version    => "3.4.2",
  :profile           => ".bash_profile",
  :shell             => "bash",
  :home_dir          => ENV["HOME"],
  :set_version       => "global",
  :do_pyenv          => false,
}

default[:pyenv][:versions_path]     = "#{node[:pyenv][:install_path]}/versions"
default[:pyenv][:python_build_path] = "#{node[:pyenv][:install_path]}/plugins/python-build"
default[:pyenv][:profile_path]      = "#{node[:pyenv][:home_dir]}/#{node[:pyenv][:profile]}"

case node[:pyenv][:set_version]
when "global" then
  default[:pyenv][:pyenv_version_file] = "#{node[:pyenv][:install_path]}/version"
when "local" then
  default[:pyenv][:pyenv_version_file] = "#{node[:pyenv][:home_dir]}/.python-version"
else
  raise "node[:pyenv][:set_version] = 'global' or 'local'"
end

default[:python_build_env] = {
  :default => {
    "TMPDIR"                 => nil,
    "RUBY_BUILD_BUILD_PATH"  => nil,
    "RUBY_BUILD_CACHE_PATH"  => nil,
    "RUBY_BUILD_MIRROR_URL"  => nil,
    "RUBY_BUILD_SKIP_MIRROR" => nil,
    "RUBY_BUILD_ROOT"        => nil,
    "RUBY_BUILD_DEFINITIONS" => nil,
    "PREFIX"                 => "/usr/local",
  },
  :make => {
    "CC"                     => nil,
    "RUBY_CFLAGS"            => nil,
    "CONFIGURE_OPTS"         => nil,
    "MAKE"                   => nil,
    "MAKE_OPTS"              => nil,
    "MAKE_INSTALL_OPTS"      => nil,
    "RUBY_CONFIGURE_OPTS"    => nil,
    "RUBY_MAKE_OPTS"         => nil,
    "RUBY_MAKE_INSTALL_OPTS" => nil,
  }
}

default[:pyenv][:pyenv_bin]        = "#{node[:pyenv][:install_path]}/bin/pyenv"
default[:pyenv][:python_build_bin] = "#{node[:python_build_env][:default]['PREFIX']}/bin/python-build"
