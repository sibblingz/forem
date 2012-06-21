module Forem
  class View < ActiveRecord::Base
    belongs_to :topic, :counter_cache => true
    belongs_to :user, :class_name => Forem.user_class.to_s

    validates :topic_id, :presence => true
  end
end
