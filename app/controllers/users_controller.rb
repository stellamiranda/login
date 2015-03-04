require 'twilio-ruby'

class UsersController < ApplicationController

    include Webhookable
 
    after_filter :set_header
 
    skip_before_action :verify_authenticity_token

    def text_response
        user = User.find(params[:id].to_i)
        response = Twilio::TwiML::Response.new do |r|
            r.Say 'Hello ' + user.username + ' your code is ', :voice => 'alice'
            r.Pause :length => 3
            user.code.to_s.split('').each do |digit|
                r.Say digit, :voice => 'alice'
                r.Pause :length => 1   
            end
        end
        render_twiml response
    end

  	private

  	def user_params
  		params.require(:user).permit( :username, :celphone, :password)
  	end

end