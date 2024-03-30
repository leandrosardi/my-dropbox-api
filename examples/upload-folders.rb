#require 'my-dropbox-api'
require_relative '../lib/my-dropbox-api' # switch to this line when you are working on the gem

# Create a new client
BlackStack::DropBox.set({
    :vymeco_api_key => '<your connectionsphere api key here>',
    :dropbox_refresh_token => '<your refresh token here>',
})

# Create a local folder
Dir.mkdir('/tmp/my-second-folder')

# Ceate a local sub-folder
Dir.mkdir('/tmp/my-second-folder/my-second-sub-folder')

# Create a local file into the sub-folder
File.open('/tmp/my-second-folder/my-second-sub-folder/my-second-file.txt', 'w') { |file| file.write('Hello World!') }

# Upload file
ret = BlackStack::DropBox.upload('/tmp/my-second-folder', '/')
puts ret.join("\n\n")