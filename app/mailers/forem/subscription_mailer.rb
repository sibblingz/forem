module Forem
  class SubscriptionMailer < ActionMailer::Base
    default :from => Forem.email_from_address
    
    def topic_reply(post_id, subscriber_id)
      # only pass id to make it easier to send emails using resque
      @post = Post.find(post_id)
      @user = Forem.user_class.find(subscriber_id)
      
      mail(:to => @user.email, :subject => "Spaceport Forum: Topic '#{@post.topic}' has received a reply from #{@post.user.forum_nickname_display}")
    end
  end
end
