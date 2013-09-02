require 'pathname'

module ApeBox

  def self.mailer message=''
    system("/usr/bin/printf \"to: alessio.peternelli@gmail.com, deborah@incipitonline.it\r\nContent-Type: text/plain; charset=utf8 \r\nsubject: messaggio da check_and_restore su wbf2\r\n\r\n  #{message}\" | /usr/bin/sendmail alessio.peternelli@gmail.com deborah@incipitonline.it")
  end

  def self.shellescape(str)
    # An empty argument will be skipped, so return empty quotes.
    return "''" if str.empty?
    str = str.dup
    # Process as a single byte sequence because not all shell
    # implementations are multibyte aware.
    str.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/n, "\\\\\\1")
    # A LF cannot be escaped with a backslash because a backslash + LF
    # combo is regarded as line continuation and simply ignored.
    str.gsub!(/\n/, "'\n'")
    return str
  end

  module Backup
    # Database Data Container
    # -----------------------------------------------------------------------------------------------------------
    class DataBaseConnectionStructure
      attr_accessor :host, :name, :user, :pass
      # Dump structure and data to a file, defaults to dbname.sql
      # -------------------------------------------
      def dump_to_file filename=nil
        raise "Missing param host" if @host.empty?
        raise "Missing param name" if @name.empty?
        raise "Missing param user" if @user.empty?
        raise "Missing param pass" if @pass.empty?

        filename = "#{@name}.sql" if filename.nil?
        system "touch #{filename}" unless Pathname(filename).exist?
        raise "Invalid file "+filename unless Pathname(filename).writable_real?

        %x(mysqldump --user=#{@user} --password='#{@pass}' --host=#{@host} --databases #{@name} > #{filename} 2>&1)
      end
    end

    # Parse a Wordpress wp-config.php and return a DataBaseConnectionStructure
    # object for dumping
    # ----------------------------------------------------------------------------------------------------------
    def self.parse_wordpress filename
      raise "Invalid file "+filename unless Pathname(filename).readable_real?
      file = File.open filename
      code = file.read
      data = DataBaseConnectionStructure.new

      # Database Host
      match = Regexp.new("define[ ]*\\([ ]*['\"]+DB_HOST['\"]+[ ]*,[ ]*['\"]+([^'\"]+)['\"]+").match code
      raise "Param host not found" if match.nil?
      data.host = match[1]

      # Database Name
      match = Regexp.new("define[ ]*\\([ ]*['\"]+DB_NAME['\"]+[ ]*,[ ]*['\"]+([^'\"]+)['\"]+").match code
      raise "Param name not found" if match.nil?
      data.name = match[1]

      # Database Username
      match = Regexp.new("define[ ]*\\([ ]*['\"]+DB_USER['\"]+[ ]*,[ ]*['\"]+([^'\"]+)['\"]+").match code
      raise "Param user not found" if match.nil?
      data.user = match[1]

      # Database Password
      match = Regexp.new("define[ ]*\\([ ]*['\"]+DB_PASSWORD['\"]+[ ]*,[ ]*['\"]+([^'\"]+)['\"]+").match code
      raise "Param password not found" if match.nil?
      data.pass = match[1]

      return data
    end

    # Parse a Joomla! configuration.php and return a DataBaseConnectionStructure
    # object for dumping
    # ----------------------------------------------------------------------------------------------------------
    def self.parse_joomla filename
      raise "Invalid file "+filename unless Pathname(filename).readable_real?
      file = File.open filename
      code = file.read
      data = DataBaseConnectionStructure.new

      # Database Host
      match = Regexp.new("\\$host[ ]*=[ ]*['\"]+([^'\"]+)['\"]+").match code
      raise "Param host not found" if match.nil?
      data.host = match[1]

      # Database Name
      match = Regexp.new("\\$db[ ]*=[ ]*['\"]+([^'\"]+)['\"]+").match code
      raise "Param name not found" if match.nil?
      data.name = match[1]

      # Database Username
      match = Regexp.new("\\$user[ ]*=[ ]*['\"]+([^'\"]+)['\"]+").match code
      raise "Param user not found" if match.nil?
      data.user = match[1]

      # Database Password
      match = Regexp.new("\\$password[ ]*=[ ]*['\"]+([^'\"]+)['\"]+").match code
      raise "Param password not found" if match.nil?
      data.pass = match[1]

      return data
    end

    def self.list_backups(path, filter='.*')
      reg_filter = Regexp.new("backup_[0-9]+_#{filter}_filesystem\.tar\.gz$", Regexp::IGNORECASE)
      Dir.entries(path).select {|n| n =~ reg_filter}
    end

    def self.list_backups_tarsnap(tarsnap_bin, filter='.*')
      list = %x("#{tarsnap_bin}" --list-archives)
      list = list.split "\n"
      reg_filter = Regexp.new("_#{filter}_filesystem$", Regexp::IGNORECASE)
      list.select {|n| n =~ reg_filter}
    end

    class Logger

      attr_accessor :file, :stdout, :colorize
      def initialize filename=nil, stdout=true, colors=false
        @file = filename.nil? ? nil : filename
        @stdout = stdout
        @colorize = colors
      end

      def info message
        put_tofile "[INFO] #{message}" unless @file.nil?
        if @stdout
          message = "\e[36m#{message}\e[0m" if @colorize
          put_tostdout message
        end
      end

      def error message
        put_tofile "[ERROR] #{message}" unless @file.nil?
        if @stdout
          message = "\e[31m#{message}\e[0m" if @colorize
          put_tostdout message
        end
      end

      def good message
        put_tofile "[OK] #{message}" unless @file.nil?
        if @stdout
          message = "\e[32m#{message}\e[0m" if @colorize
          put_tostdout message
        end
      end

      private

      def put_tofile message
        check_file
        unless @file.nil?
          File.open @file, "a+" do |file|
            message.gsub! /[\r\n]+/, '-'
            file.write "\n[#{Time.now}] #{message}"
          end
        end
      end

      def put_tostdout message
        puts message
      end

      def check_file
        if @file.is_a? String
          system "touch #{@file}" unless Pathname(@file).exist?
          raise "Invalid file "+filename unless Pathname(@file).writable_real?
        else
          @file = nil
        end
      end

    end

  end
end
