require 'daemons'
PWD = File.dirname(__FILE__)
opts = {
  :app_name => 'omcktwitterbot',
  :log => PWD + "/log/",
  :dir => PWD + "/log/",
  :log_output => true,
  :monitor => true,
  :keep_pid_files => true,
  :multiple => true
}
Daemons.run("app.rb",opts)
