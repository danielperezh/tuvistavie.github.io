class Article < ActiveRecord::Base
    attr_accessible :content, :title

    def to_param
        [id, title.parameterize].join("-")
    end

end
