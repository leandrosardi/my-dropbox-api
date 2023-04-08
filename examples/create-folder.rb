#require 'my-dropbox-api'
require_relative '../lib/my-dropbox-api' # switch to this line when you are working on the gem

# Create a new client
BlackStack::DropBox.set({
    :connectionsphere_api_key => '<your connectionsphere api key here>',
    :dropbox_refresh_token => '<your refresh token here>',
})

# Create a folder
puts BlackStack::DropBox.dropbox_create_folder('/my-first-folder')
# => {"metadata": {"name": "my-first-folder", "path_lower": "/my-first-folder", "path_display": "/my-first-folder", "id": "id:Vtyvsunm9sMAAAAAAAAACA"}}

# Create a sub-folder
puts BlackStack::DropBox.dropbox_create_folder('/my-first-folder/my-first-sub-folder')
# => {"metadata": {"name": "my-first-sub-folder", "path_lower": "/my-first-folder/my-first-sub-folder", "path_display": "/my-first-folder/my-first-sub-folder", "id": "id:Vtyvsunm9sMAAAAAAAAACQ"}}
