#!/usr/bin/ruby

require 'yaml'

load 'ape_box.rb'

conf = YAML.load_file('config.yaml')
Dir.chdir conf["source"]
Dir.foreach Dir.pwd do |name|
  # "path" must be a fully qualified directory name
  # "name" refer only to the base name
  path = conf["source"][-1] == '/' ? conf["source"]+name : conf["source"]+'/'+name

  # throw/cath used to prune directories, there is a better/cleaner way ?
  catch :excluded_path do
    throw :excluded_path unless FileTest.directory? name
    throw :excluded_path if name[0] == '.'

    puts "\nParsing #{path}"
    # Check if path contain a wordpress or joomla installation othervire prune!
    case true
      when (FileTest.exist? path+'/wp-config.php') then
        puts "It's a Wordpress installation!"
        begin
          data = ApeBox::Backup.parse_wordpress path+'/wp-config.php'
        rescue Exception => e
          puts "-----------------------------------------------------------------"
          puts e.message
          throw :excluded_path
        end
      when (FileTest.exist? path+'/configuration.php') then
        puts "It's a Joomla! installation!"
        begin
          data = ApeBox::Backup.parse_joomla path+'/configuration.php'
        rescue Exception => e
          puts "-----------------------------------------------------------------"
          puts e.message
          throw :excluded_path
        end
      else
        puts "I don't recognize any installation to backup!"
        throw :excluded_path
    end
    puts "Database : " + data.name

    begin
      dump = conf["backup"]+'/'+name+'.sql'
      puts "Dumping on #{dump}"
      o = data.dump_to_file dump
    rescue Exception => e
      o = e.message
    end

    case o
      when nil then
        puts "[KO] Sembra che non sia installato mysqldump"
      when true then
        puts "[OK] Dump avvenuto con successo"
      when false then
        puts "[KO] Errore nel dumping"
      else
        puts o
    end
  end
end

