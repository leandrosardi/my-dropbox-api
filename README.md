![GitHub issues](https://img.shields.io/github/issues/leandrosardi/my-dropbox-api) ![GitHub](https://img.shields.io/github/license/leandrosardi/my-dropbox-api) ![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/leandrosardi/my-dropbox-api) ![GitHub last commit](https://img.shields.io/github/last-commit/leandrosardi/my-dropbox-api)


#### Why Not Amazon S3?

**Cost Considerations:** Even if S3 can handle the load, keep in mind that increased operations may lead to higher costs. Amazon charges per API request, and high volumes of upload operations will raise your expenses.


# my-dropbox-api

The **my-dropbox-api** is a Ruby gem for managing DropBox uploading, downloading and sharing DropBox files and folders.

The main goals of building this gem are:

1. Simulate a **permanent access token**, since [Dropbox is moving to "short-term live access codes"](https://www.dropboxforum.com/t5/Discuss-Dropbox-Developer-API/Permanent-access-token/td-p/592644);

2. Manage DropBox as an elastic-storage providers for [our SaaS projects](https://github.com/leandrosardi/mysaas), allowing us to upload, download and share download links to files;

3. Backup and restore secret files of our projects that cannot be commited into the source code repository (E.g.: database passwords, SSL certificates, private keys).

## 1. Getting DropBox Refresh Token

1. Open a new browser, and login to your DropBox account.

2. In the same browser, go to this link:
https://www.dropbox.com/oauth2/authorize?client_id=lnystcoayzse5at&token_access_type=offline&response_type=code

3. Follow the steps, and copy the "Access Code" to your clipboard.
![image](https://user-images.githubusercontent.com/55877846/215112803-4f4b08b3-5fa5-45f9-ac27-b1d1aba5ba2e.png)

4. Since Dropbox's "Access Codes" are short-term lived, you need to generate a "Refresh Token".
We have published a helper page where you can get such a Refresh Token:
https://connectionsphere.com/developers/dss

Note that you have to signup to ConnectionSphere to access this screen.

![image](https://user-images.githubusercontent.com/55877846/215155561-ed1c915f-e585-49bd-957d-4e9cc60d3f02.png)


After you have performed these steps, you can find a new `/Apps/mysaas-backups`, as is shown in the picture below.

![Image](https://user-images.githubusercontent.com/55877846/227719530-1d0ce570-0844-49cb-a33f-f91538b97e84.png)

All the files and folders managed by **my-dropbox-api** will be scoped to that folder.

## 2. Getting ConnectionSphere API Key

1. Signup to ConnectionSphere [here](https://connectionsphere.com/signup).

2. Get your API-KEY [here](https://connectionsphere.com/settings/apikey).

## 3. Getting Started

Install **my-dropbox-api** gem.

```bash
gem install my-dropbox-api
```

Setup **my-dropbox-api** to access DropBox account.

```ruby
requires 'my-dropbox-api'

BlackStack::DropBox.set({
    :vymeco_api_key => '118f3c32-c920-******',
    :dropbox_refresh_token => 'dh4UcV4dFVs******',
})
```

## 4. Creating Folders

```ruby
# Create a folder
puts BlackStack::DropBox.dropbox_create_folder('/my-first-folder')
# => {"metadata": {"name": "my-first-folder", "path_lower": "/my-first-folder", "path_display": "/my-first-folder", "id": "id:Vtyvsunm9sMAAAAAAAAACA"}}

# Create a sub-folder
puts BlackStack::DropBox.dropbox_create_folder('/my-first-folder/my-first-sub-folder')
# => {"metadata": {"name": "my-first-sub-folder", "path_lower": "/my-first-folder/my-first-sub-folder", "path_display": "/my-first-folder/my-first-sub-folder", "id": "id:Vtyvsunm9sMAAAAAAAAACQ"}}
```

## 5. Uploading Files

```ruby
# Create a local folder

# Create a local file
File.open('/tmp/my-first-file.txt', 'w') { |file| file.write('Hello World!') }

# Upload file
puts BlackStack::DropBox.dropbox_upload_file('/tmp/my-first-file.txt', '/my-first-folder/my-first-file.txt')
# => {"name": "my-first-file.txt", "path_lower": "/my-first-folder/my-first-file.txt", "path_display": "/my-first-folder/my-first-file.txt", "id": "id:Vtyvsunm9sMAAAAAAAAACw", "client_modified": "2023-03-25T14:20:36Z", "server_modified": "2023-03-25T14:20:37Z", "rev": "5f7ba36b1776ce01d7d61", "size": 12, "is_downloadable": true, "content_hash": "61f417374f4400b47dcae1a8f402d4f4dacf455a0442a06aa455a447b0d4e170"}
```

## 6. Uploading Folder Structures

Use `BlackStack::DropBox.upload` if you want to upload a folder, with all its sub-folders and files, recusivelly.

This method returns an array with a hash descritor of each operation performed.

```ruby
# Create a local folder
Dir.mkdir('/tmp/my-second-folder')

# Ceate a local sub-folder
Dir.mkdir('/tmp/my-second-folder/my-second-sub-folder')

# Create a local file into the sub-folder
File.open('/tmp/my-second-folder/my-second-sub-folder/my-second-file.txt', 'w') { |file| file.write('Hello World!') }

# Upload file
ret = BlackStack::DropBox.upload('/tmp/my-second-folder', '/')
puts ret.join("\n")
# => {:file=>"my-second-folder", :type=>"folder", :result=>"{\"metadata\": {\"name\": \"my-second-folder\", \"path_lower\": \"/my-second-folder\", \"path_display\": \"/my-second-folder\", \"id\": \"id:Vtyvsunm9sMAAAAAAAAAEQ\"}}"}
# => {:file=>"my-second-sub-folder", :type=>"folder", :result=>"{\"metadata\": {\"name\": \"my-second-sub-folder\", \"path_lower\": \"/my-second-folder/my-second-sub-folder\", \"path_display\": \"/my-second-folder/my-second-sub-folder\", \"id\": \"id:Vtyvsunm9sMAAAAAAAAAEg\"}}"}
# => {:file=>"my-second-file.txt", :type=>"file", :result=>"{\"name\": \"my-second-file.txt\", \"path_lower\": \"/my-second-folder/my-second-sub-folder/my-second-file.txt\", \"path_display\": \"/my-second-folder/my-second-sub-folder/my-second-file.txt\", \"id\": \"id:Vtyvsunm9sMAAAAAAAAAEw\", \"client_modified\": \"2023-03-25T15:17:28Z\", \"server_modified\": \"2023-03-25T15:17:28Z\", \"rev\": \"5f7bb020690c7e01d7d61\", \"size\": 12, \"is_downloadable\": true, \"content_hash\": \"61f417374f4400b47dcae1a8f402d4f4dacf455a0442a06aa455a447b0d4e170\"}"}
```

## 7. Getting Download Link of a File

```ruby
# Get download link for a file
puts BlackStack::DropBox.get_file_url('/.pages/383ff473-b649-4cf0-9090-a41022c8d6c4.html')
# => https://dl.dropboxusercontent.com/s/9bgveh24fm89v4i/my-first-file.txt?dl=1
```

## 8. Advanced: Managing Secret Files of Your Project

_(**WARNING:** This section is pending of documentation)_

## 9. Advanced: Creating Your Own DropbBox App.

_(**WARNING:** This section has not been tested yet)_

If you want to register your own DropBox APP, instead to use **ConnectionSphere**, follow the steps below:

1. Signup to DropBox [here](https://www.dropbox.com/register) or login to an existing account [here](https://www.dropbox.com/login).

2. Go to your DropBox's account home [here](https://www.dropbox.com/home), and double-check you are logged into.

3. Go to [DropBox Developers Center](https://www.dropbox.com/developers/apps/).

4. Click on the "Create app" button.

5. In the step 1 (Choose an API), choose "Scoped access".

6. In the step 2 (Choose the type of access you need), choose "App folder".

7. In the step 3 (Name your app), write "mysaas-backup".

8. Agree with the "Dropbox API Terms and Conditions", and click on "Create app".

You will be redirected to your new app's configuration page.
If you didn't, just go to [https://www.dropbox.com/developers/apps](https://www.dropbox.com/developers/apps) in your browser.

Now, you have to setup your app's permissions.

9. Click on the "Permissions" tab.

10. Check the "files.metadata.write", "files.content.write" and "files.content.read" options.

11. Scroll down and click on "Submit".

Finally, you have to grab your API key.

12. In the same screen, go to the "Settings".

13. Scroll down click on "Generate access token". 

14. Grab the `DropBox App Key` and `DropBox App Secret` and add them to your configuration.

```ruby
BlackStack::DropBox.set({
    :dropbox_refresh_token => '<past your access token here>',
    # if you are using your own DropBox App
    :dropbox_app_key => '....',
    :dropbox_app_secret => '....'
})
```