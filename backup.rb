#!/usr/bin/ruby

##
# Set PWD and CONFIGURATION variables and load libraries
##
pwd = File.dirname(__FILE__)
require 'yaml'
require pwd+'/ape_box.rb'
conf = YAML.load_file(pwd+'/config.yaml')

##
# Check for arguments passed to the script
# actually only configuration override
##
ARGV.each do |arg|
  key = arg.split('=')[0]
  value = arg.split('=')[1]

  if conf.has_key? key
    conf[key] = value
  end
end

##
# Setup time and log settings
##
today       = Time.now
date_string = sprintf("backup_%04d%02d%02d", today.year, today.month, today.day)
logfile     = conf['log_to_file'] ? conf['log_file'] : nil
log         = ApeBox::Backup::Logger.new(logfile, conf['log_to_stdout'], true)

Dir.chdir conf["webapps_directory"]
Dir.foreach Dir.pwd do |name|
  ##
  # "path" must be a fully qualified directory name
  # "name" refer only to the base name
  ##
  path = conf["webapps_directory"][-1] == '/' ? conf["webapps_directory"]+name : conf["webapps_directory"]+'/'+name

  ##
  # throw/cath used to prune directories, there is a better/cleaner way ?
  ##
  catch :excluded_path do
    throw :excluded_path unless FileTest.directory? name
    throw :excluded_path if name[0] == '.'

    ##
    # Recognize e parse installation
    # --------------------------------------------------------------------------
    #
    # Check if path contain a wordpress or joomla installation otherwise: prune!
    # TODO rewrite the code in a object oriented way
    ##
    log.info "\nParsing #{path}"
    case true

      ##
      # Wordpress Blog
      # -------------------------------------------------------------
      ##
      when (FileTest.exist? path+'/wp-config.php') then
        log.good "It's a Wordpress installation!"
        begin
          data = ApeBox::Backup.parse_wordpress path+'/wp-config.php'
        rescue Exception => e
          log.error "#{e.message}"
          ApeBox::mailer "Error: #{e.message}\r\nName: #{name}\r\n"
          throw :excluded_path
        end

        ##
        # Joomla! CMS
        #-------------------------------------------------------------
        ##
      when (FileTest.exist? path+'/configuration.php') then
        log.good "It's a Joomla! installation!"
        begin
          data = ApeBox::Backup.parse_joomla path+'/configuration.php'
        rescue Exception => e
          log.error "#{e.message}"
          ApeBox::mailer "Error: #{e.message}\r\nName: #{name}\r\n"
          throw :excluded_path
        end

        ##
        # Unknown Application
        #-------------------------------------------------------------
        ##
      else
        log.info "I don't recognize any application to backup in this path!"
        throw :excluded_path
    end
    log.good "Database is #{data.name}"

    ##
    # Dump the database and Backup everything
    # -----------------------------------------------
    ##
    begin
      dump = conf["tmp_directory"]+'/'+name+'.sql'
      log.good "Dumping on #{dump}"
      dump_response = data.dump_to_file dump
      if $?.exitstatus == 0 && dump_response == '' 
        log.good "Dump success"
      else
        if dump_response.is_a? String
          log.error "Dump error (#{dump_response})"
          ApeBox::mailer  "Dump error (#{dump_response})\r\nName: #{name}\r\n"
        else
          log.error "Dump error (unknown)"
          ApeBox::mailer  "Dump error (unknown)\r\nName: #{name}\r\n"
        end
      end

      if dump_response
        if conf["tarsnap"] === true || conf["tarsnap"] === 'true'
          log.info "Tarsnapping #{name}"
          tbin = conf["tarsnap_bin"]
          system "#{tbin} -cf #{date_string}_#{name}_database #{dump}"
          system "#{tbin} -cf #{date_string}_#{name}_filesystem #{path}"
        end
        if conf["targz"] === true || conf["targz"] === 'true'
          log.info "Tar&Gzipping #{name}"
          system "tar -czf #{conf["backup_directory"]}/#{date_string}_#{name}_database.tar.gz #{dump}"
          system "tar -czf #{conf["backup_directory"]}/#{date_string}_#{name}_filesystem.tar.gz #{path}"
        end
      end
      system "rm #{dump}"
    rescue Exception => e
      log.error "#{e.message}"
      ApeBox::mailer "Error: #{e.message}\r\nName: #{name}\r\n"
    end

  end
end

