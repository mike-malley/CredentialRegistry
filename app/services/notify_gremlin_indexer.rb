# Pushes a message to the Redis queue that activates the Gremlin indexer.
class NotifyGremlinIndexer
  LIST = 'gremlin-cer:waiting'.freeze
  CREATE_INDICES = 'create_indices'.freeze
  INDEX_ONE = 'index_one'.freeze
  INDEX_ALL = 'index_all'.freeze
  DELETE_ONE = 'delete_one'.freeze

  class << self
    def index_one(id)
      MR.redis_pool.with do |redis|
        redis.lpush(LIST, build_message(INDEX_ONE, id))
      end
    end

    def index_all
      MR.redis_pool.with do |redis|
        redis.lpush(LIST, build_message(INDEX_ALL))
      end
    end

    def delete_one(id)
      MR.redis_pool.with do |redis|
        redis.lpush(LIST, build_message(DELETE_ONE, id))
      end
    end

    def create_indices
      MR.redis_pool.with do |redis|
        redis.lpush(LIST, build_message(CREATE_INDICES))
      end
    end

    private

    def build_message(command, id = nil)
      { command: command, id: id }.to_json
    end
  end
end
