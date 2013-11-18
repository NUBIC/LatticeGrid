def public_path
  "#{File.expand_path(Rails.root)}/public"
end

def root_path
  "#{File.expand_path(Rails.root)}"
end

def clear_directory(dir_name)
  name="#{public_path()}/#{dir_name}"
  if File.directory?(name) then
    begin
     logger.info "running 'rm -r #{name}'"
    rescue Exception => error
      puts "running 'rm -r #{name}'"
    end
    system("rm -r #{name}")
  end
end

def clear_file(file_name)
  name="#{public_path()}/#{file_name}"
  if File.exist?(name) then
    begin
     logger.info "running 'rm #{name}'"
    rescue Exception => error
      puts "running 'rm #{name}'"
    end
    system("rm #{name}")
  end
end
