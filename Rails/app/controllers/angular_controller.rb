class AngularController < ActionController::Base
    def index
        render file: File.join(Rails.root, 'public/index.html'), layout: false
    end
end
