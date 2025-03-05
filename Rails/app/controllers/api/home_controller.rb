module Api
  class HomeController < ApplicationController
    def index
      render json: { 
        requests: last_requests.as_json(
          except: %i[user_id created_at updated_at],
          include: {
            preset_requests: {
              except: %i[request_id color_id filament_id printer_id],
              include: {
                color: { only: %i[id name] },
                filament: { only: %i[id name] },
                printer: { only: %i[id model] }
              }
            },
            user: {
              only: %i[id username],
              include: {
                country: { only: %i[name] }
              }
            }
          },
          methods: %i[stl_file_url has_offer_made? accepted_at]
        ),
        submissions: last_submissions.as_json(
          include: :likes, 
          methods: %i[stl_url image_url]
        ),
        contests: last_contests.as_json(
          include: :submissions, 
          methods: %i[image_url finished? started? winner_user]
        )
      }, status: :ok
    end

    private

    def last_requests
      Request.order('created_at DESC').limit(6)
    end

    def last_submissions
      Submission.order('created_at DESC').limit(6)
    end

    def last_contests
      Contest.order('start_at DESC').where('start_at < ?', Date.today).limit(6)
    end
  end
end