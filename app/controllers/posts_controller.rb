class PostsController < ApplicationController
  include ActionView::RecordIdentifier
  before_action :set_post, only: %i[ edit update destroy ]
  before_action :is_author?, only: [:edit, :update, :destroy]
  
  # GET /posts
  def index
    #@posts = Post.all.order("created_at DESC")
    #se kathe selida emfanizw 5 posts me prwto to pio neotera created
    @pagy, @posts = pagy(Post.order(created_at: :desc), items: 5)
    #mporw na dhmiourghsw neo post apo to index
    @post = Post.new
  end

  # GET /posts/1
  def show
    @post = Post.find_by(id: params[:id])
    #an enas user thelei na dei ena post poy exei diagrafei, ton kanw redirect sto index
    #px an vlepei to post kai ekeinh th stigmh o owner to diagrapsei, an kanei refresh, tha metavei sto index
    if @post.nil?
      #@pagy, @posts = pagy(Post.order(created_at: :desc), items: 5)
      #flash.now[:alert] = "Post was not found"
      #render "index"
      redirect_to posts_path, alert: "Post was not found"
    end
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  def create
    @post = current_user.posts.new(post_params)

    respond_to do |format|
      if @post.save
        #create.turbo_stream.erb
        #update the page mono gia ton current_user pou kanei to action
        #katharizei ti forma kai deixnei to flash message mono ston current user
        format.turbo_stream { flash.now[:notice] = "Post #{@post.id} was successfully created." }
        format.html { redirect_to posts_path, notice: "Post #{@post.id} was successfully created." }
      else
        flash.now[:alert] = "Something went wrong"

        format.turbo_stream do
          render turbo_stream: [
            #kalw apo ton application_helper gia na kanw render to flash message
            helpers.render_flash_messages 
          ]
        end
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  def update
    #to xrhsimopoiousa otan edeixna ta buttons [edit, delete] se olous tous users kai oxi mono ston owner

    #if current_user != @post.user
    #  respond_to do |format|
    #    format.turbo_stream { flash.now[:alert] = "You don't have the rights to edit this post." }
    #    format.html { redirect_to @post, alert: "You don't have the rights to edit this post." }
    #  end
    #else
      respond_to do |format|
        if @post.update(post_params)
          #update.turbo_stream.erb
          #deixnei to flash message mono ston current user
          format.turbo_stream { flash.now[:notice] = "Post #{@post.id} was successfully updated." }
          format.html { redirect_to post_url(@post), notice: "Post was successfully updated." }
        else
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    #end
  end

  # DELETE /posts/1
  def destroy
    #to xrhsimopoiousa otan edeixna ta buttons [edit, delete] se olous tous users kai oxi mono ston owner

    #if current_user != @post.user
    #  respond_to do |format|
    #    flash.now[:alert] = "You don't have the rights to delete this post."
    #    format.turbo_stream do 
    #      render turbo_stream: [
    #        helpers.render_flash_messages
    #      ]
    #    end
    #    format.html { redirect_to @post, alert: "You don't have the rights to delete this post." }
    #  end
    #else
      @post.destroy
      
      respond_to do |format|
        #destroy.turbo_frame.erb
        #deixnei to flash message mono ston current user
        format.turbo_stream { flash.now[:notice] = "Post #{@post.id} was successfully destroyed." }
        format.html { redirect_to posts_path, notice: "Post was successfully destroyed." }
      end
    #end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      # Avoid N+1 queries
      # Preload both body and attachments.
      @post = Post.with_rich_text_body_and_embeds.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      #gia na dexetai rich_text prepei na kanw permit to attribute body
      params.require(:post).permit(:body)
    end

    #an o user den einai o owner tou post den mporei na to kanei edit kai delete
    def is_author?
      redirect_to @post, alert: "You don't have the rights to edit or delete this post." unless @post.user == current_user
    end
end
