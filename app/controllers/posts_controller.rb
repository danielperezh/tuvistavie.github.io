class PostsController < ApplicationController
  before_filter :authenticate_admin!, :except => [:index, :show]

  # GET /posts
  def index
    if params[:tag].nil?
      posts = Post.with_translations(I18n.locale)
    else
      posts = Post.find_by_tag(params[:tag])
    end

    @content_limit = Settings.posts["content_limit_#{I18n.locale.to_s}"]

    page = params[:page].nil? ? 1 : params[:page]
    @posts = posts.paginate(:page => page).order('posts.created_at DESC')
  end

  # GET /posts/1
  def show
    @post = Post.find(params[:id])
    @confirmation = false
    @comments_count = @post.comments.count
    @using_fallback = !@post.translated_locales.include?(I18n.locale)
  end

  # post /posts/1/confirm
  def confirm
    @post = Post.new(params[:post])
    @confirmation = true
    render 'show'
  end

  def confirm_update
    @post = Post.find(params[:id])
    @post.update_attributes(params[:post])
    @confirmation = true
    render 'show'
  end

  # GET /posts/new
  def new
    @post = Post.new
    @action = :confirm
  end

  # GET /posts/1/edit
  def edit
    @post = Post.find(params[:id])
    @post.translated_attribute_names.each do |attr|
      @post[attr] = '' if @post.translation[attr].nil?
    end
    @action = :confirm_update
  end

  # POST /posts
  def create
    upload_files(params[:files])
    @post = Post.new(params[:post])

    if @post.save
      redirect_to @post, :notice => 'Post was successfully created.'
    else
      render :action => "new"
    end
  end

  # PUT /posts/1
  def update
    upload_files(params[:files])
    @post = Post.find(params[:id])

    if @post.update_attributes(params[:post])
      redirect_to @post, :notice => 'Post was successfully updated.'
    else
      render :action => "edit"
    end
  end

  # DELETE /posts/1
  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    redirect_to posts_path
  end
end
