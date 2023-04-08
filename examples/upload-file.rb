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

# Create a local file
File.open('/tmp/my-first-file.txt', 'w') { |file| file.write('Hello World!') }

# Upload file
puts BlackStack::DropBox.dropbox_upload_file('/tmp/my-first-file.txt', '/my-first-folder/my-first-file.txt')
# => {"name": "my-first-file.txt", "path_lower": "/my-first-folder/my-first-file.txt", "path_display": "/my-first-folder/my-first-file.txt", "id": "id:Vtyvsunm9sMAAAAAAAAACw", "client_modified": "2023-03-25T14:20:36Z", "server_modified": "2023-03-25T14:20:37Z", "rev": "5f7ba36b1776ce01d7d61", "size": 12, "is_downloadable": true, "content_hash": "61f417374f4400b47dcae1a8f402d4f4dacf455a0442a06aa455a447b0d4e170"}
