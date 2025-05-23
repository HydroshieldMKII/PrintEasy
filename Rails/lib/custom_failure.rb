# frozen_string_literal: true

class CustomFailure < Devise::FailureApp
  def respond
    self.status = 401
    self.content_type = 'json'
    self.response_body = { 'errors' => { 'connection' => ['Invalid login credentials'] } }.to_json
  end
end
