#!/usr/bin/ruby

require 'yaml'
require './ape_box'

conf = YAML.load_file('config.yaml')
Dir.chdir conf["webapps_directory"]
Dir.foreach Dir.pwd do |name|
  # "path" must be a fully qualified directory name
  # "name" refer only to the base name
  path = conf["webapps_directory"][-1] == '/' ? conf["webapps_directory"]+name : conf["webapps_directory"]+'/'+name

  # throw/cath used to prune directories, there is a better/cleaner way ?
  catch :excluded_path do
    throw :excluded_path unless FileTest.directory? name
    throw :excluded_path if name[0] == '.'

    puts "\n\e[34mParsing #{path}\e[0m"
    # Recognize e parse installation
    # --------------------------------------------------------------------------
    #
    # Check if path contain a wordpress or joomla installation otherwise: prune!
    # TODO rewrite the code in a object oriented way
    case true
      # Wordpress Blog
      # -------------------------------------------------------------
      when (FileTest.exist? path+'/wp-config.php') then
        puts "\e[32mIt's a Wordpress installation!\e[0m"
        begin
          data = ApeBox::Backup.parse_wordpress path+'/wp-config.php'
        rescue Exception => e
          puts "\e[31m#{e.message}\e[0m"
          throw :excluded_path
        end
      # Joomla! CMS
      #-------------------------------------------------------------
      when (FileTest.exist? path+'/configuration.php') then
        puts "\e[32mIt's a Joomla! installation!\e[0m"
        begin
          data = ApeBox::Backup.parse_joomla path+'/configuration.php'
        rescue Exception => e
          puts "\e[31m#{e.message}\e[0m"
          throw :excluded_path
        end
        # Unknown Application
      else
        puts "\e[34mI don't recognize any application to backup in this path!\e[0m"
        throw :excluded_path
    end
    puts "\e[32mDatabase is #{data.name}\e[0m"

    # Dump the database
    # -----------------------------------------------
    begin
      dump = conf["backup_directory"]+'/'+name+'.sql'
      puts "\e[32mDumping on #{dump}\e[0m"
      dump_response = data.dump_to_file dump
      puts "\e[31m[KO] Maybe mysqldump is missing !\e[0m" if dump_response.nil?
      puts dump_response ? "\e[32m[OK] Dump success\e[0m" : "\e[31m[KO] Dump errror\e[0m"
    rescue Exception => e
      puts "\e[31m#{e.message}\e[0m"
    end

  end
end

