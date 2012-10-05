require 'pathname'

module ApeBox
  module Backup
    class DataBaseConnectionStructure
      attr_accessor :host, :name, :user, :pass
      def dump_to_file filename
        raise "Missing param host" if @host.empty?
        raise "Missing param name" if @name.empty?
        raise "Missing param user" if @user.empty?
        raise "Missing param pass" if @pass.empty?
        raise "Invalid file "+filename unless Pathname(filename).writable_real?
        system "mysqldump --user=#{@user} --password=#{@pass} --host=#{@host} --databases #{@name} > #{filename}"
      end
    end

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

  end
end