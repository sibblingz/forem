module Forem
  class AccessGroup < ActiveRecord::Base
    attr_accessible :forum_id, :group_id
    belongs_to :forum, :inverse_of => :access_groups
    belongs_to :group
  end
end
