# -*- coding: utf-8 -*-
rails_root = File.expand_path("../../", __FILE__)
# rails_env = ENV["RAILS_ENV"] || "development"

sock_path = "/var/socks/unicorn.harukash.sock"

ENV["BUNDLE_GEMFILE"] = rails_root + "/Gemfile"
worker_processes 2
working_directory rails_root

worker_processes Integer(ENV["WEB_CONCURRENCY"] || 1)
timeout 150

stderr_path rails_root + "/log/unicorn.log"
stdout_path rails_root + "/log/unicorn_error.log"

# ダウンタイムをなくす
preload_app true

# listen 8080
# listen '/run/unicorn/unicorn.sock'
listen sock_path

pid rails_root + "/tmp/unicorn.pid"

# 再起動時古いプロセスを落とす
before_fork do |server, worker|
  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      puts "Sending #{sig} signal to old unicorn master..."
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
  sleep 1
end

after_fork do |_server, _worker|
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
end
