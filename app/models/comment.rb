class Comment < ActiveRecord::Base
  attr_accessible :content, :gravatar_name, :name

  belongs_to :comment
end
