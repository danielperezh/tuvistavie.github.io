class PostsController < ApplicationController
  before_filter :authenticate_admin!, except: [:index, :show]
  before_filter :set_post, only: [:show, :confirm_update, :update, :edit, :destroy]

  def index
    if params[:tag].nil?
      posts = Post.with_translations(I18n.locale)
    else
      posts = Post.find_by_tag(params[:tag])
    end

    @content_limit = Settings.posts["content_limit_#{I18n.locale.to_s}"]

    posts = posts.published unless admin_signed_in?

    page = params[:page].nil? ? 1 : params[:page]
    @posts = posts.paginate(page: page).order('posts.created_at DESC')
  end

  def show
    @confirmation = false
    @comments_count = @post.comments.count
    @using_fallback = !@post.translated_locales.include?(I18n.locale)
  end

  def confirm
    @post = Post.new(post_params)
    @confirmation = true
    @back_page = new_post_path
    render 'show'
  end

  def confirm_update
    @post.update_attributes(post_params)
    @confirmation = true
    @back_page = edit_post_path(@post)
    render 'show'
  end

  def new
    @post = Post.new(params[:post])
    @action = :confirm
  end

  def edit
    @post.translated_attribute_names.each do |attr|
      @post[attr] = '' if @post.translation[attr].nil?
    end
    @post.assign_attributes(post_params) if request.post?
    @action = :confirm_update
  end

  def create
    upload_files(params[:files])
    @post = Post.new(post_params)

    if @post.save
      redirect_to @post, notice: 'Post was successfully created.'
    else
      render :new
    end
  end

  def update
    upload_files(params[:files])

    if @post.update_attributes(post_params)
      redirect_to @post, notice: 'Post was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_path
  end

  private

  def set_post
    if admin_signed_in?
      @post = Post.find(params[:id])
    else
      @post = Post.published.find(params[:id])
    end
  end

  def post_params
    params.require(:post).permit(
      :content, :title,  :friendly_id, :main_picture,
      :published, tags_attributes: [:id, :name, :_destroy, :locale]
    )
  end
end
