module Forem
  class Subscription < ActiveRecord::Base
    belongs_to :topic
    belongs_to :subscriber, :class_name => Forem.user_class.to_s
    validates_presence_of :subscriber_id

    def send_notification(post_id)
      # do not send any emails when using the 'local' stage
      return if CONFIGURATION['stage'] == 'local'

      # only send emails when the user's email address matches the 'authenticate_email_filter' from the configuration.yml file
      filter = CONFIGURATION['authenticate_email_filter']
      regexp = Regexp.new filter
      match = regexp.match self.subscriber.email
      if match
        SubscriptionMailer.topic_reply(post_id, self.subscriber.id).deliver
      else
        logger.warn "this user (#{self.subscriber.email}) is not allowed to use this site (authenticate_email_filter=#{filter}), so don't deliver mail"
      end
    end
  end
end
