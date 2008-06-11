module AfterCommit
  def self.committed_records
    @@committed_records ||= []
  end

  def self.committed_records=(committed_records)
    @@committed_records = committed_records
  end
  
  def self.committed_records_on_create
    @@committed_records_on_create ||= []
  end
  
  def self.committed_records_on_create=(committed_records)
    @@committed_records_on_create = committed_records
  end
  
  def self.committed_records_on_update
    @@committed_records_on_update ||= []
  end
  
  def self.committed_records_on_update=(committed_records)
    @@committed_records_on_update = committed_records
  end
  
  def self.committed_records_on_destroy
    @@committed_records_on_destroy ||= []
  end
  
  def self.committed_records_on_destroy=(committed_records)
    @@committed_records_on_destroy = committed_records
  end
end
