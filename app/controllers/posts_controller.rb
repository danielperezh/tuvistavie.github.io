class PostsController < ApplicationController
  before_filter :authenticate_admin!, :except => [:index, :show]

  # GET /posts
  # GET /posts.json
  def index
    if params[:tag].nil?
      posts = Post.with_translations(I18n.locale)
    else
      posts = Post.find_by_tag(params[:tag])
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
    manage_tags(@post, tags_hash)

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
    manage_tags(@post, tags_hash)

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
  def destroy
    @post = Post.find(params[:id])
    tags = @post.tags
    tags.each do |tag|
      tag.destroy if tag.posts.count == 1
    end
    @post.destroy
    redirect_to posts_path
  end

  private
  def manage_tags(post, tags)
    return if tags.nil?
    tags.each_value do |tag_hash|
      destroy = tag_hash.delete(:_destroy)
      if tag_hash.has_key?(:id)
        manage_existing_tag(post, tag_hash, destroy)
      else
        manage_new_tag(post, tag_hash)
      end
    end
  end

  def manage_existing_tag(post, tag_hash, destroy)
    tag = Tag.find(tag_hash[:id])
    if destroy == "1"
      post.tags.delete(tag)
      tag.destroy if tag.posts.count == 0
    else
      tag.update_attributes(tag_hash)
    end
  end

  def manage_new_tag(post, tag_hash)
    tag = Tag.find_by_name(tag_hash[:name], tag_hash[:locale])
    if tag.nil?
      post.tags.build(:name => tag_hash[:name], :locale => tag_hash[:locale])
    else
      post.tags << tag
    end
  end

end
