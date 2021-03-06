require 'active_support/concern'
require 'notify_gremlin_indexer'
require 'rdf_index_job'

# When included schedule for indexing by Gremlin.
module GremlinIndexable
  extend ActiveSupport::Concern

  included do
    after_commit :notify_indexer_update, on: %i[create update]

    def notify_indexer_update
      RdfIndexJob.perform_later(id)

      if deleted_at? && previous_changes.key?('deleted_at')
        NotifyGremlinIndexer.delete_one(id)
      else
        NotifyGremlinIndexer.index_one(id)
      end
    end
  end
end
