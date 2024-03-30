require 'pry'
require 'json'
require 'blackstack-core'

module BlackStack
    module DropBox
        DROPBOX_APP_KEY = 'lnystcoayzse5at'
        
        # ConnectionSphere API-KEY
        @@vymeco_api_key = nil
        @@vymeco_token_url = 'http://vymeco.com:3000/api1.0/dropbox-token-helper/get_access_token.json'
        
        # mysaas end-user "refresh-token" to grab a new "access-code" every time is needed.
        @@dropbox_refresh_token = nil
        # list of folders and files to backup
        @@destinations = []

        # getters 
        def self.dropbox_refresh_token
            @@dropbox_refresh_token
        end

        # getters 
        def self.destinations
            @@destinations
        end

        # Setup the bakcup module.
        def self.set(h)
            @@dropbox_refresh_token = h[:dropbox_refresh_token]
            @@destinations = h[:destinations]
            @@vymeco_api_key = h[:vymeco_api_key]
        end # set

        # Get a short-live access code using the refresh token.
        # This method is for internal usage only.
        # End-users should not call this method.
        #
        def self.dropbox_get_access_token
            # get the refresh token
            begin
                params = {
                  'api_key' => "#{@@vymeco_api_key}",
                  'refresh_token' => "#{@@dropbox_refresh_token}"
                }
                res = BlackStack::Netting::call_post(@@vymeco_token_url, params)
                h = JSON.parse(res.body)
                raise h['status'] if h['status']!='success'

                h['access_token']
            rescue Errno::ECONNREFUSED => e
                raise "Errno::ECONNREFUSED:#{e.message}"
            rescue => e2
                raise "Exception:#{e2.message}"
            end
        end

        # Create a folder into dropbox
        #
        # This method is for internal use only.
        # End-users should use the BlackStack::Backup::backup method.
        # 
        # use `2>&1 1>/dev/null` to suppress verbose output of shell command.
        # reference: https://stackoverflow.com/questions/18525359/suppress-verbose-output-of-shell-command-in-python
        def self.dropbox_create_folder(cloudfoldername)
            s = "curl --silent -X POST https://api.dropboxapi.com/2/files/create_folder_v2 \\
            --header \"Authorization: Bearer #{BlackStack::DropBox.dropbox_get_access_token}\" \\
            --header \"Content-Type: application/json\" \\
            --data \"{\\\"autorename\\\":false,\\\"path\\\":\\\"#{cloudfoldername}\\\"}\""
            `#{s}`
        end

        # Upload a file to dropbox
        #
        # This method is for internal use only.
        # End-users should use the BlackStack::Backup::backup method.
        # 
        # use `2>&1 1>/dev/null` to suppress verbose output of shell command.
        # reference: https://stackoverflow.com/questions/18525359/suppress-verbose-output-of-shell-command-in-python
        def self.dropbox_upload_file(localfilename, cloudfilename)
            s = "curl --silent -X POST https://content.dropboxapi.com/2/files/upload \\
            --header \"Authorization: Bearer #{BlackStack::DropBox.dropbox_get_access_token}\" \\
            --header \"Dropbox-API-Arg: {\\\"path\\\": \\\"#{cloudfilename}\\\", \\\"mode\\\": \\\"overwrite\\\"}\" \\
            --header \"Content-Type: application/octet-stream\" \\
            --data-binary @#{localfilename}"
            return `#{s}`
        end

        # Upload a files and folders to dropbox
        #
        # This method is for internal use only.
        # End-users should use the BlackStack::Backup::backup method.
        # 
        # Iterate over directories and subdirectories recursively showing 'path/file'.
        # reference: https://stackoverflow.com/questions/40016856/iterate-over-directories-and-subdirectories-recursively-showing-path-file-in-r
        #
        # localpath: pattern to list the files and folders to upload
        # cloudpath: name of the cloud folder
        #
        # Return an array of each opeation performed, with the result of such operation.
        #
        def self.upload(localpath, cloudpath)
            # drop last / from cloudpath
            cloudpath.strip!
            cloudpath.gsub!(/\/$/, '')
            # get the path from the ls command
            local_folder = localpath.gsub(/\/#{Regexp.escape(localpath.split('/').last)}$/, '')
            ret = [] # array
            Dir.glob(localpath).each do |file|
                # hash descriptor of this operation
                h = {}
                h[:file] = file
                # decide if it is a file or a folder
                type = File.directory?(file) ? 'folder' : 'file'
                # remove the source from the path
                file.gsub!(/^#{Regexp.escape(local_folder)}\//, '')
                if type == 'file'
                    h[:type] = 'file'
                    h[:result] = BlackStack::DropBox.dropbox_upload_file("#{local_folder}/\"#{file}\"", "#{cloudpath}/\"#{file}\"")
                    ret << h
                else
                    h[:type] = 'folder'
                    h[:result] = BlackStack::DropBox.dropbox_create_folder("#{cloudpath}/#{file}")
                    ret << h
                    ret += BlackStack::DropBox.upload("#{local_folder}/#{file}/*", "#{cloudpath}/#{file}")
                end # if type
            end # Dir.glob
            ret
        end

        # Run the backup process.
        def self.backup(verbose=false, log=nil)
            log = BlackStack::DummyLogger.new(nil) if log.nil?
            timestamp = Time.now.getutc.to_s.gsub(/[^0-9a-zA-Z\.]/, '')
            @@destinations.each { |d|
                # parameters
                foldername = d[:folder] # how to name this backup in dropbox 
                source = d[:source] # source folder to backup

                # build a unique folder name using the current timestamp.
                log.logs "#{foldername}... "
                    folder = "#{timestamp}.#{foldername}"
                    
                    log.logs "Create folder #{folder}... "
                    BlackStack::DropBox::dropbox_create_folder(folder, verbose)
                    log.done
                    
                    log.logs "Upload files... "
                    BlackStack::DropBox::upload(folder, source, verbose, log)
                    log.done
                log.done
            }
        end

        # Run the restore process
        #
        # NOTE: Download a folder from the user's Dropbox, as a zip file. 
        # The folder must be less than 20 GB in size and any single file within must be less than 4 GB in size. 
        # The resulting zip must have fewer than 10,000 total file and folder entries, including the top level folder. 
        # The input cannot be a single file. Note: this endpoint does not support HTTP range requests.
        # 
        # Reference: https://www.dropbox.com/developers/documentation/http/documentation#files-download_zip
        # 
        # Parameters: 
        # - cloudfoldername: name of the folder in dropbox to download. The zip file will be saved in the folder where the command is running.
        # - zipfilename: name of the zip file to save.
        # - unzip: activate thisf lag if you want to unzip the downloaded zip file.
        # - destination: path of the local folder where you want to unzip.
        # - deletezipfile: activate this if you want to delete the zip file after unzipping.
        #
        # Activate the unzip if you have installed the zip command.
        # Reference: https://iq.direct/blog/49-how-to-unzip-file-on-ubuntu-linux.html 
        #
        def self.restore(cloudfoldername, log=nil, zipfilename='temp.zip', unzip=false, destination=nil, deletezipfile=false)
            log.logs 'Downloading backup folder... '
            s = "curl --silent -X POST https://content.dropboxapi.com/2/files/download_zip \\
            --header \"Authorization: Bearer #{BlackStack::DropBox.dropbox_get_access_token}\" \\
            --header \"Dropbox-API-Arg: {\\\"path\\\":\\\"/#{cloudfoldername}/\\\"}\" --output #{zipfilename} 2>&1 1>/dev/null"
            `#{s}`

            log.done

            if unzip
                log.logs 'Unzipping backup folder... '
                s = "
                rmdir ./tempy 2>/dev/null;
                mkdir ./tempy;
                unzip #{zipfilename} -d ./tempy;
                mv ./tempy/#{cloudfoldername}/* #{destination};
                rm -rf ./tempy 2>/dev/null;
                "
                `#{s}`
                log.done
                if deletezipfile
                    log.logs 'Deleting zip file... '
                    `rm #{zipfilename}`
                    log.done
                end
            end
        end # def self.restore

        def self.dropbox_download_file(cloudfoldername, cloudfilename, destination=nil)
            s = "curl --silent -X POST https://content.dropboxapi.com/2/files/download \\
            --header \"Authorization: Bearer #{BlackStack::DropBox.dropbox_get_access_token}\" \\
            --header \"Dropbox-API-Arg: {\\\"path\\\":\\\"/#{cloudfoldername}/#{cloudfilename}\\\"}\" --output #{destination}/#{cloudfilename} 2>&1 1>/dev/null"
            `#{s}`
        end # def self.dropbox_download_file

        # Reference: https://www.dropbox.com/developers/documentation/http/documentation#files-list_folder
        def self.dropbox_folder_files(cloudfoldername)
            s = "curl --silent -X POST https://api.dropboxapi.com/2/files/list_folder \\
            --header \"Authorization: Bearer #{BlackStack::DropBox.dropbox_get_access_token}\" \\
            --header \"Content-Type: application/json\" \\
            --data \"{\\\"include_deleted\\\":false,\\\"include_has_explicit_shared_members\\\":false,\\\"include_media_info\\\":false,\\\"include_mounted_folders\\\":true,\\\"include_non_downloadable_files\\\":true,\\\"path\\\":\\\"/#{cloudfoldername}/\\\"}\""
            output = `#{s}`
            ret = JSON.parse(output)
            ret['entries'].map { |e| e['name'] }
        end # def self.dropbox_folder_files

        # Reference: https://www.dropbox.com/developers/documentation/http/documentation#sharing-create_shared_link_with_settings
        def self.get_file_url(cloudfilename)
            s = "curl --silent -X POST https://api.dropboxapi.com/2/sharing/create_shared_link_with_settings \\
            --header \"Authorization: Bearer #{BlackStack::DropBox.dropbox_get_access_token}\" \\
            --header \"Content-Type: application/json\" \\
            --data \"{\\\"path\\\":\\\"#{cloudfilename}\\\",\\\"settings\\\":{\\\"access\\\":\\\"viewer\\\",\\\"allow_download\\\":true,\\\"audience\\\":\\\"public\\\",\\\"requested_visibility\\\":\\\"public\\\"}}\""
            output = JSON.parse(`#{s}`)
            raise "Error: #{output['error_summary']}" if output.has_key?('error_summary')
            url = output["url"]
            url.gsub!('www.dropbox.com', 'dl.dropboxusercontent.com') # Gsub domain
            url.gsub!('dl=0', 'dl=1') # Enable download
            url
        end  # def self.get_file_url

    end # module Extensions
end # module BlackStack
