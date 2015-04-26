# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

VMControl::Application.load_tasks

task :workers => :environment do
  module Delayed
    class Worker
      def name_with_thread_id(*a, &b)
        name_without_thread_id(*a, &b) + " thread:#{Thread.current.object_id}"
      end
      alias_method_chain :name, :thread_id
    end
  end
  Rails.logger.info "Running threaded worker env."

  Delayed::Worker.lifecycle.around(:execute) do |*args, &block|
    thread_num = (ActiveRecord::Base.connection_config[:pool] || 1)
    threads = []
    Rails.logger.info "Using #{thread_num} threads for the worker."
    thread_num.times do
      threads << Thread.new(&block)
    end
    threads.each(&:join)
    Rails.logger.info "End of threads."
  end

  Rake::Task["jobs:work"].execute
end