namespace :gremlin do
  desc 'Creates indices for the CER entities in the Gremlin database.'
  task create_indices: :cer_environment do
    require 'notify_gremlin_indexer'
    NotifyGremlinIndexer.create_indices
  end

  desc 'Reindexes the envelope database in Gremlin.'
  task index_all: :cer_environment do
    require 'notify_gremlin_indexer'
    NotifyGremlinIndexer.index_all
  end

  desc "Attempts to reindex documents that haven't been indexed yet."
  task index_not_indexed: :cer_environment do
    require 'notify_gremlin_indexer'
    ids = Envelope.not_deleted
                  .where(last_graph_indexed_at: nil)
                  .ordered_by_date
                  .pluck(:id)
                  .reverse
    ids.each { |id| NotifyGremlinIndexer.index_one(id) }
  end

  desc 'Updates the JSON context specs used to inform indexing.'
  task update_contexts: :environment do
    require 'json_context'
    urls = Envelope.select("distinct processed_resource->>'@context' as url").map(&:url)
    urls.each do |url|
      next if url.blank?
      puts "Updating context for #{url}."
      context = JSON.parse(RestClient.get(url).body)
      JsonContext.find_or_initialize_by(url: url).tap do |ctx|
        ctx.context = context
        ctx.save!
        puts 'Updated.'
      end
    end
    NotifyGremlinIndexer.update_contexts
  end
end
