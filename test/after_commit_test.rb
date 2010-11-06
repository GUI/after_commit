$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')
require 'test/unit'
require 'rubygems'
require 'activerecord'
require 'after_commit'
require 'after_commit/active_record'
require 'after_commit/connection_adapters'

ActiveRecord::Base.establish_connection({"adapter" => "sqlite3", "database" => 'test.sqlite3'})
begin
  ActiveRecord::Base.connection.execute("drop table mock_records")
  ActiveRecord::Base.connection.execute("drop table mock_non_callbacks")
rescue
end
ActiveRecord::Base.connection.execute("create table mock_records(id int)")
ActiveRecord::Base.connection.execute("create table mock_non_callbacks(id int)")

require File.dirname(__FILE__) + '/../init.rb'

class MockNonCallback < ActiveRecord::Base; end

class MockRecord < ActiveRecord::Base
  attr_accessor :after_commit_called
  attr_accessor :after_commit_on_create_called
  attr_accessor :after_commit_on_update_called
  attr_accessor :after_commit_on_destroy_called
  
  def clear_flags
    @after_commit_called = @after_commit_on_create_called = @after_commit_on_update_called = @after_commit_on_destroy_called = nil
  end
  
  after_commit :do_commit
  def do_commit
    raise "Re-called on commit!" if self.after_commit_called
    self.after_commit_called = true
    MockNonCallback.transaction{ MockNonCallback.create! }
  end

  after_commit_on_create :do_create
  def do_create
    raise "Re-called on create!" if self.after_commit_on_create_called
    self.after_commit_on_create_called = true
    MockNonCallback.transaction{ MockNonCallback.create! }
  end

  after_commit_on_update :do_update
  def do_update
    raise "Re-called on update!" if self.after_commit_on_update_called
    self.after_commit_on_update_called = true
    MockNonCallback.transaction{ MockNonCallback.create! }
  end

  after_commit_on_destroy :do_destroy
  def do_destroy
    raise "Re-called on destroy!" if self.after_commit_on_destroy_called
    self.after_commit_on_destroy_called = true
    MockNonCallback.transaction{ MockNonCallback.create! }
  end
end

class AfterCommitTest < Test::Unit::TestCase
  def test_after_commit_on_create_is_called
    assert_equal true, MockRecord.create!.after_commit_on_create_called
  end

  def test_after_commit_on_update_is_called
    record = MockRecord.create!
    record.clear_flags
    record.save
    assert_equal true, record.after_commit_on_update_called
  end

  def test_after_commit_on_destroy_is_called
    record = MockRecord.create!
    record.clear_flags
    assert_equal true, record.destroy.after_commit_on_destroy_called
  end
end
