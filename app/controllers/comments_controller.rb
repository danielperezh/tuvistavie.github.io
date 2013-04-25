class CommentsController < ApplicationController
  before_filter :authenticate_admin!, :only => [:destroy]

  # GET /posts/1/comments
  def index
    post = Post.find(params[:post_id])
    @comments = post.comments
    puts YAML::dump(@comments)
    render :json => @comments
  end

  # POST /posts/1/comments
  def create
    post = Post.find(params[:post_id])
    @comment = post.comments.build(params[:comment])
    unless @comment.answer_to_id.nil?
      original_comment = Comment.find(@comment.answer_to_id)
      @comment.answer_to_id = original_comment.answer_to_id unless original_comment.answer_to_id.nil?
    end
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
