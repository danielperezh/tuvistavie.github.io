class PostsController < ApplicationController
  before_filter :authenticate_admin!, :except => [:index, :show]
  before_filter :set_fallbacks, :except => [:edit]

  # GET /posts
  # GET /posts.json
  def index
    if params[:tag].nil?
      posts = Post.with_translations(I18n.locale)
    else
      ids = Tag.where(:name => params[:tag]).first.posts.pluck(:id)
      posts = Post.with_translations(I18n.locale).where(:id => ids)
    end

    @content_limit = Settings.posts['content_limit_' + I18n.locale.to_s]

    page = params[:page].nil? ? 1 : params[:page]
    @posts = posts.paginate(:page => page).order('posts.created_at DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @posts }
    end
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @post = Post.find(params[:id])

    @using_fallback = !@post.translated_locales.include?(I18n.locale)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @post }
    end
  end

  # GET /posts/new
  # GET /posts/new.json
  def new
    @post = Post.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @post }
    end
  end

  # GET /posts/1/edit
  def edit
    @post = Post.find(params[:id])
    @post.translated_attribute_names.each do |attr|
      @post[attr] = '' if @post.translation[attr].nil?
    end
  end

  # POST /posts
  # POST /posts.json
  def create
    params[:post][:friendly_id] = params[:post][:title] if I18n.locale == :en
    tags_hash = params[:post].delete(:tags_attributes)
    @post = Post.new(params[:post])
    @post.add_tags!(tags_hash) if !tags_hash.nil?

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, :notice => 'Post was successfully created.' }
        format.json { render :json => @post, :status => :created, :location => @post }
      else
        format.html { render :action => "new" }
        format.json { render :json => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.json
  def update
    params[:post][:friendly_id] = params[:post][:title] if I18n.locale == :en
    tags_hash = params[:post].delete(:tags_attributes)
    @post = Post.find(params[:id])
    @post.add_tags!(tags_hash) if !tags_hash.nil?

    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.html { redirect_to @post, :notice => 'Post was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post = Post.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.html { redirect_to posts }
      format.json { head :no_content }
    end
  end

  def set_fallbacks
    Globalize.fallbacks = {:en => [:en, :ja], :ja => [:ja, :en] }
  end

end
