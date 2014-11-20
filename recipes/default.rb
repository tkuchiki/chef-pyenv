package "git"

git node[:pyenv][:install_path] do
  action           node[:pyenv][:action]
  repository       node[:pyenv][:repo_uri]
  revision         node[:pyenv][:revision]
  depth            node[:pyenv][:depth]            if node[:pyenv][:depth]
  destination      node[:pyenv][:destination]      if node[:pyenv][:destination]
  enable_checkout  node[:pyenv][:enable_checkout]  if node[:pyenv][:enable_checkout]
  enable_submodule node[:pyenv][:enable_submodule] if node[:pyenv][:enable_submodule]
  user             node[:pyenv][:user]             if node[:pyenv][:user]
  group            node[:pyenv][:group]            if node[:pyenv][:group]
  provider         node[:pyenv][:provider]         if node[:pyenv][:provider]
  remote           node[:pyenv][:remote]           if node[:pyenv][:remote]
  ssh_wrapper      node[:pyenv][:ssh_wrapper]      if node[:pyenv][:ssh_wrapper]
  timeout          node[:pyenv][:timeout]          if node[:pyenv][:timeout]
end

install_python_build_env = {}

node[:python_build_env][:default].map do |key, value|
  install_python_build_env[key] = value unless value.nil?
end

bash "install python-build" do
  cwd         node[:pyenv][:python_build_path]
  environment install_python_build_env
  creates     node[:pyenv][:python_build_bin]

  code        <<-EOC
bash ./install.sh
EOC
end

make_python_env = {}

node[:python_build_env][:make].map do |key, value|
  make_python_env[key] = value unless value.nil?
end

install_python_path = "#{node[:pyenv][:versions_path]}/#{node[:pyenv][:python_version]}"

bash "install python #{node[:pyenv][:python_version]}" do
  environment make_python_env
  creates     "#{install_python_path}"

  code        <<-EOC
  #{node[:pyenv][:python_build_bin]} #{node[:pyenv][:python_version]} #{install_python_path}
EOC
end

file node[:pyenv][:profile_path] do
  f = Chef::Util::FileEdit.new(path)

  insert_lines = "
export PYENV_ROOT=\"#{node[:pyenv][:install_path]}\"
export PATH=\"$PYENV_ROOT/bin:$PATH\"
eval \"$(pyenv init - #{node[:pyenv][:shell]})\"
"

  f.insert_line_if_no_match(/export\s+PYENV_ROOT/, insert_lines)

  if Gem::Version.new(node[:chef_packages][:chef][:version]) >= Gem::Version.new("11.12.0")
    content f.send(:editor).lines.join
  else
    content f.send(:contents).join
  end
end

bash "pyenv #{node[:pyenv][:set_version]} #{node[:pyenv][:python_version]}" do
  code <<-EOC
#{node[:pyenv][:pyenv_bin]} #{node[:pyenv][:set_version]} #{node[:pyenv][:python_version]}
#{node[:pyenv][:pyenv_bin]} rehash
EOC

  only_if {
    node[:pyenv][:do_pyenv] &&
    (!File.exists?(node[:pyenv][:pyenv_version_file]) ||
    (File.exists?(node[:pyenv][:pyenv_version_file]) &&
    IO.read(node[:pyenv][:pyenv_version_file]).gsub(/[\r\n]/, "") != node[:pyenv][:python_version]))
  }
end
