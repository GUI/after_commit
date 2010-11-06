require 'rubygems'
require 'ruby-debug'
Debugger.start
module AfterCommit
  @@records = {}
  @@records_queue = []
  
  @@record_methods = {
    :all => :committed_records,
    :create => :committed_records_on_create,
    :update => :committed_records_on_update,
    :destroy => :committed_records_on_destroy
  }
  
  @@callback_methods = {
    :all => :after_commit_callback,
    :create => :after_commit_on_create_callback,
    :update => :after_commit_on_update_callback,
    :destroy => :after_commit_on_destroy_callback
  }
  
  def self.records
    @@records
  end
  
  # Push a new variable holder onto our stack.
  def self.push
    @@records_queue.push @@records
    @@records = {}
  end
  
  def self.pop
    @@records = @@records_queue.pop
  end
  
  # Send callbacks of this type after a commit.
  # We push a new variable holder on each record, then pop it off, which avoids
  # an infinite loop whereby an on_commit callback makes a new transaction
  # (like in creating a BackgrounDRb record)
  def self.callback(crud_method, &block)
    record_method = @@record_methods[crud_method]
    callback_method = @@callback_methods[crud_method]
    committed_records = send(record_method)
    
    unless committed_records.empty?
      committed_records.each do |record|
        push
        record.send(callback_method)
        pop
      end
    end
    
    records[crud_method] = []
  end
  
  def self.clear!
    @@records = {}
    @@records_queue = []
  end
  
  def self.committed_records
    records[:all] ||= []
  end

  def self.committed_records=(committed_records)
    records[:all] = committed_records
  end
  
  def self.committed_records_on_create
    records[:create] ||= []
  end
  
  def self.committed_records_on_create=(committed_records)
    records[:create] = committed_records
  end
  
  def self.committed_records_on_update
    records[:update] ||= []
  end
  
  def self.committed_records_on_update=(committed_records)
    records[:update] = committed_records
  end
  
  def self.committed_records_on_destroy
    records[:destroy] ||= []
  end
  
  def self.committed_records_on_destroy=(committed_records)
    records[:destroy] = committed_records
  end
end
