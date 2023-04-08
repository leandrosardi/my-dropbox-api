#require 'my-dropbox-api'
require_relative '../lib/my-dropbox-api' # switch to this line when you are working on the gem

# Create a new client
BlackStack::DropBox.set({
  :connectionsphere_api_key => '<your connectionsphere api key here>',
  :dropbox_refresh_token => '<your refresh token here>',
})

# Get download link for a file
puts BlackStack::DropBox.get_file_url('/.pages/383ff473-b649-4cf0-9090-a41022c8d6c4.html')
# => https://dl.dropboxusercontent.com/s/9bgveh24fm89v4i/my-first-file.txt?dl=1