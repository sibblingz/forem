module Forem
  class SubscriptionMailer < ActionMailer::Base
    default :from => Forem.email_from_address
    
    def topic_reply(post_id, subscriber_id)
      # only pass id to make it easier to send emails using resque
      @post = Post.find(post_id)
      @user = Forem.user_class.find(subscriber_id)
      
      filter = CONFIGURATION['authenticate_email_filter']
      regexp = Regexp.new filter
      match = regexp.match @user.email
      
      if match
        mail(:to => @user.email, :subject => "A topic you are subscribed to has received a reply")
      else
        logger.error "this user (#{@user.email}) is not allowed to use this site (authenticate_email_filter=#{CONFIGURATION['authenticate_email_filter']}), so don't deliver mail"
      end
    end
  end
end
