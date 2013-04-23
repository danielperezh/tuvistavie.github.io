class CommentsController < ApplicationController
  before_filter :authenticate_admin!, :only => [:destroy]

  # GET /posts/1/comments
  def index
    post = Post.find(params[:post_id])
    @comments = post.comments
    render :json => @comments
  end

  # POST /posts/1/comments
  def create
    post = Post.find(params[:post_id])
    @comment = post.comments.build(params[:comment])
    if @comment.save
      render :json => @comment #, :status => :created, :location => @comment
    else
      render :json => @comment.errors, :status => :unprocessable_entity
    end
  end

  # DELETE /posts/1/comments/1
  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy

    head :no_content
  end
end
