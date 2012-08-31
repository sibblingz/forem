module Forem
  class Category < ActiveRecord::Base
    has_many :forums, :order => "forem_forums.position ASC"
    validates :name, :presence => true

    def to_s
      name
    end

  end
end
