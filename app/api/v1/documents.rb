module API
  module V1
    # Implements all the endpoints related to documents
    class Documents < Grape::API
      resource :documents do
        get do
          { text: 'Documents list' }
        end
      end
    end
  end
end
