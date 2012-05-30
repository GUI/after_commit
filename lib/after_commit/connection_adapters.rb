module AfterCommit
  module ConnectionAdapters
    def self.included(base)
      base.class_eval do
        # The commit_db_transaction method gets called when the outermost
        # transaction finishes and everything inside commits. We want to
        # override it so that after this happens, any records that were saved
        # or destroyed within this transaction now get their after_commit
        # callback fired.
        def commit_db_transaction_with_callback          
          commit_db_transaction_without_callback
          trigger_after_commit_callbacks
          trigger_after_commit_on_create_callbacks
          trigger_after_commit_on_update_callbacks
          trigger_after_commit_on_destroy_callbacks
        end 
        alias_method_chain :commit_db_transaction, :callback

        # In the event the transaction fails and rolls back, nothing inside
        # should recieve the after_commit callback.
        def rollback_db_transaction_with_callback
          rollback_db_transaction_without_callback

          AfterCommit.clear!
        end
        alias_method_chain :rollback_db_transaction, :callback
        
        protected
          
          def trigger_after_commit_callbacks
            AfterCommit.callback(:all)
          end
        
          def trigger_after_commit_on_create_callbacks
            AfterCommit.callback(:create)
          end
        
          def trigger_after_commit_on_update_callbacks
            AfterCommit.callback(:update)
          end
        
          def trigger_after_commit_on_destroy_callbacks
            AfterCommit.callback(:destroy)
          end
        #end protected
      end 
    end 
  end
end
