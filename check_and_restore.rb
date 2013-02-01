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
scanner     = conf['clamdscan']

Dir.chdir conf["webapps_directory"]
Dir.foreach Dir.pwd do |name|
 
  ##
  # "path" must be a fully qualified directory name
  # "name" refer only to the base name
  ##
  path = conf["webapps_directory"][-1] == '/' ? conf["webapps_directory"]+name : conf["webapps_directory"]+'/'+name
  catch :excluded_path do
    throw :excluded_path unless FileTest.directory? name
    throw :excluded_path if (name[0].class == Fixnum && name[0].chr == '.')
    throw :excluded_path if (name[0].class == String && name[0] == '.')
    
    cmd_result = %x("#{scanner}" -i "#{path}" 2>&1)
    
    ##
    # Check if clamd is running
    ##
    error_check = cmd_result.scan("ERROR: Can't connect to clamd: No such file or directory").first
    unless error_check.nil?
      ApeBox::mailer "Errore:\r\n #{cmd_result}";
      throw :excluded_path
    end
    
    ##
    # Check for infected files
    ##
    scan_result = cmd_result.scan(/Infected files: [0-9]+/).first
    if scan_result.nil?
      ApeBox::mailer "Errore:\r\n #{cmd_result}";
    else
      viruses = scan_result.scan(/[0-9]+$/).first
      if viruses == '0' || viruses == 0
        #puts 'no virus'
      else
        ApeBox::mailer "è stato rillevato un virus nel sito #{name} nel percorso #{path}"
      end
    end
  end
end
