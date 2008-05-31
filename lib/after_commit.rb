module AfterCommit
  def self.committed_records
    @@committed_records ||= []
  end

  def self.committed_records=(committed_records)
    @@committed_records = committed_records
  end
end
