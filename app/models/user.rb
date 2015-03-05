require 'twilio-ruby'

class User < ActiveRecord::Base

    include Webhookable

    attr_accessor :password
    before_save :encrypt_password
  
    validates_confirmation_of :password
    validates_presence_of :celphone
    validates_presence_of :password, :on => :create
    validates_presence_of :username
    validates_uniqueness_of :username
  
    def self.authenticate(username, password)
        user = find_by_username(username)
        if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
            user
        else
            nil
        end
    end

    def self.reauthenticate(code)
        user = find_by_username(username)
        if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
            user
        else
            nil
        end
    end

    def voice
        account_sid = ENV['TWILIO_ACCOUNT_SID'] 
        auth_token = ENV['TWILIO_AUTH_TOKEN'] 
        @client = Twilio::REST::Client.new account_sid, auth_token 
     
        @client.account.calls.create({
            :url => 'http://magic-login.herokuapp.com/users/'+self.id.to_s+'/text_response/' ,
            :to => self.celphone,
            :from => '+16504828142'  
        })
        

        # sms 
    
        #@client.account.messages.create({ :body => "Your Code is" + self.code.to_s,:to => "+573005787275", :from => '+16504828142'  })

    end
  
    def encrypt_password
        if password.present?
            self.password_salt = BCrypt::Engine.generate_salt
            self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
        end
    end

    def generate_code
        code = Random.rand(999999)
        self.code = code
        self.save

    end

end