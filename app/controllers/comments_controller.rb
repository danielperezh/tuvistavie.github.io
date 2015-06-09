class CommentsController < ApplicationController
  before_filter :authenticate_admin!, only: [:destroy]

  def index
    post = Post.find(params[:post_id])
    @comments = post.comments
    render json: @comments
  end

  def create
    post = Post.find(params[:post_id])
    @comment = post.comments.build(comment_params)

    if @comment.save
      render json: @comment, status: :created
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    Comment.where(answer_to_id: @comment.id).delete_all
    @comment.destroy

    head :no_content
  end

  private

  def comment_params
    params.require(:comment).permit(:content, :gravatar_email, :author, :answer_to_id)
  end
end
