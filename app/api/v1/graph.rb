require 'mountable_api'
require 'envelope'
require 'delete_token'
require 'batch_delete_envelopes'
require 'envelope_builder'
require 'entities/envelope'
require 'entities/payload_formatter'
require 'helpers/shared_helpers'
require 'helpers/community_helpers'
require 'helpers/envelope_helpers'
require 'v1/publish'

module API
  module V1
    # Implements all the endpoints related to resources
    class Graph < MountableAPI
      mounted do
        helpers SharedHelpers
        helpers CommunityHelpers
        helpers EnvelopeHelpers

        include API::V1::Defaults
        include API::V1::Publish

        before do
          params[:envelope_community] = select_community
        end

        resource :graph do
          desc 'Return a resource. ' \
               'If the resource is part of a graph, the entire graph is returned.'
          params do
            requires :id, type: String, desc: 'Resource id.'
          end
          before do
            authenticate_community!
          end
          after_validation do
            find_envelope
          end
          get ':id', requirements: { id: /(.*)/i } do
            present PayloadFormatter.format_payload(@envelope.processed_resource)
          end
        end
      end
    end
  end
end
