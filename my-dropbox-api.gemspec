Gem::Specification.new do |s|
  s.name        = 'my-dropbox-api'
  s.version     = '1.0.2'
  s.date        = '2024-03-30'
  s.summary     = "Ruby gem to manage some basic DropBox operations."
  s.description = "
The **dropbox-api** is a Ruby gem for managing DropBox uploading, downloading and sharing DropBox files and folders.

The main goals of building this gem are:
  
1. Simulate a **permanent access token**, since [Dropbox is moving to \"short-term live access codes\"](https://www.dropboxforum.com/t5/Discuss-Dropbox-Developer-API/Permanent-access-token/td-p/592644);
  
2. Manage DropBox as an elastic-storage providers for [our SaaS projects](https://github.com/leandrosardi/mysaas), allowing us to upload, download and share download links to files;
  
3. Backup and restore secret files of our projects that cannot be commited into the source code repository (E.g.: database passwords, SSL certificates, private keys).
  "
  s.authors     = ["Leandro Daniel Sardi"]
  s.email       = 'leandro@connectionsphere.com'
  s.files       = [
    'lib/my-dropbox-api.rb',
  ]
  s.homepage    = 'https://github.com/leandrosardi/my-dropbox-api'
  s.license     = 'MIT'
  s.add_runtime_dependency 'json', '~> 2.6.3', '>= 2.6.3'
  s.add_runtime_dependency 'pry', '~> 0.14.2', '>= 0.14.2'
  s.add_runtime_dependency 'blackstack-core', '~> 1.2.3', '>= 1.2.3'
end