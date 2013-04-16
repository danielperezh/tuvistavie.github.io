class StaticController < ApplicationController
  def index
    @posts = Post.limit(5).order("created_at ASC")
  end
end
