require 'entities/organization'
require 'helpers/shared_helpers'
require 'organization'
require 'policies/organization_policy'

module API
  module V1
    # Organization API endpoints
    class Organizations < Grape::API
      helpers SharedHelpers

      resources :organizations do
        desc 'Returns all the organizations'
        get do
          present Organization.order(:name), with: API::Entities::Organization
        end

        desc 'Creates a new organization'
        before do
          authenticate!
        end
        params do
          requires :name, type: String, desc: 'Organization name'
        end
        post do
          authorize Organization, :create?
          organization = current_user.admin.organizations.create!(params)
          present organization, with: API::Entities::Organization
        end
      end
    end
  end
end
