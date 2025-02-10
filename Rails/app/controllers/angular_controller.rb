class AngularController < ApplicationController
    def index
        render file: 'public/index.html', layout: false
    end
end
