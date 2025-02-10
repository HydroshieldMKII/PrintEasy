class AngularController < ApplicationController
    def index
        render file: '../../public/browser/index.html', layout: false
    end
end
