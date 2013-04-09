class StaticController < ApplicationController
  def index
    @articles = Article.limit(5).order("created_at ASC")
  end
end
