class PostsController < ApplicationController
  include ActionView::RecordIdentifier
  before_action :set_post, only: %i[ edit update destroy ]
  #before_action :is_author?, only: [:edit, :update, :destroy]
  POSTS_PER_PAGE = 5
  COMMENTS_PER_POST_PAGE = 5
  # GET /posts
  # Sto index pou emfanizw ola ta posts, thelw na kanw kai to search
  # Ean o user kanei search sta dyo search forms, yparxoyn 3 periptwseis
  # Gia kathe mia apo autes, allazw to @posts pou xrhsimopoiw gia na kanw render ta posts
  def index
    # PERIPTWSH 1 - An exei ginei submit mono to search gia query
    if params[:query].present? && !params[:username].present?
      @cursor = params[:cursor]
      @posts = Post
                    .search_text(params[:query])  # thelw mono ta posts pou periexoun ta params[:query]
                    .where(@cursor ? ["posts.id < ?", @cursor] : nil)
                    .order(id: :desc).take(POSTS_PER_PAGE)
      @next_cursor = @posts.last&.id
      @more_pages = @next_cursor.present? && @posts.count == POSTS_PER_PAGE

      render "scrollable_list" if params[:cursor]
    # PERIPTWSH 2 - An exei ginei submit mono to search gia username
    elsif  params[:username].present? && !params[:query].present?
      @cursor = params[:cursor]
      @posts =  Post
                    .search_username(params[:username]) # thelw mono ta posts pou periexoun ta params[:username]
                    .where(@cursor ? ["posts.id < ?", @cursor] : nil)
                    .order(id: :desc).take(POSTS_PER_PAGE)
      @next_cursor = @posts.last&.id
      @more_pages = @next_cursor.present? && @posts.count == POSTS_PER_PAGE

      render "scrollable_list" if params[:cursor]
    # PERIPTWSH 3 - An exei ginei submit kai to search gia query kai gia username
    elsif  params[:query].present? && params[:username].present?
      @cursor = params[:cursor]
      @posts =  Post
                    .search_username(params[:username]).search_text(params[:query]) # thelw ta posts pou periexoun ta params[:username] kai params[:query]
                    .where(@cursor ? ["posts.id < ?", @cursor] : nil)
                    .order(id: :desc).take(POSTS_PER_PAGE)
      @next_cursor = @posts.last&.id
      @more_pages = @next_cursor.present? && @posts.count == POSTS_PER_PAGE

      render "scrollable_list" if params[:cursor]
    # NO SEARCH - ean den exei ginei search (default) kanw render ola ta posts se descending order
    else 
      # CURSOR-BASED PAGINATION
      # se oles tis periptwseis den thelw na emfanizontai ola ta post se mia selida alla thelw mono POSTS_PER_PAGE ana selida
      # kathe unique key pou mporw na kanw order by mporei na xrhsimopoiithei ws cursor, opote tha xrhsimopoiwsw to id twn posts san cursor
      # kathe epomeno post tha exei id < apo to cursor, etsi akoma kai an diagrafei to post tou cursor, to epomeno post tha ginei returned swsta

      # Thelw na petyxw kati san infinite scrolling, opou h epomenh selida twn posts emfanizetai katw apo to teleutaio kathe fora pou ftanw sto telos tis selidas
      # Epeidh tin idia stigmh thelw na kanw create kai delete posts se real time, auto shmainei pws otan afairw ena post allazei kai i lista twn posts se kathe selida
      # kai ean xrhsimopoiousa ena gem (px pagy) pou xrhsimopoiei offset pagination, den tha epistrefontan ta swsta posts tis epomenhs selidas
      # px. an exw [A, B, C, D, E, F] posts kai kathe selida exei 3 h prwth tha exei ta [A, B, C] 
      # ean afairesw to B tha exoun meinei [A, C] stin prwth selida kai synolika sto database [A, C, D, E, F]
      # Parolo pou sto 1o page exw mono 2 results anti gia 3, to 2o page tha xrhsimopoihsei tin updated database.
      # Etsi otan kanw request to 2o page, tha nomizei oti to D einai meros tou 1ou page, kai tha prosthesei ta epomena 3 posts (se auth thn periptwsh ta 2 pou menoun) : [A, C, E, F]
      # To post D leipei.
      # Me to cursor based pagination, anti na zhthsw ta posts tou next page, zhtaw to epomeno post meta to C, ara tha parw to swsto set twn post: [A, C, D, E, F]
      @cursor = params[:cursor]
      @posts = Post
                    .where(@cursor ? ["id < ?", @cursor] : nil) # to epomeno post na exei mikrotero id apo to id tou cursor
                    .order(id: :desc)                           # ola ta posts kata fthinousa seira
                    .take(POSTS_PER_PAGE)                       # kathe fora thelw na ginontai return POSTS_PER_PAGE (px. 5) posts
      
      @next_cursor = @posts.last&.id  # thetw next_cursor to teletaio post tis listas
      @more_pages = @next_cursor.present? && @posts.count == POSTS_PER_PAGE
      render "scrollable_list" if params[:cursor] # kanw render to template scrollable_list mesw tou unique id tou turbo_frame tou next_page partial
                                                  # se auto kanw render ta posts me id < cursor kai sth synexeia ksanakanw render to next_page partial
    end
    #mporw na dhmiourghsw neo post apo to index
    @post = Post.new
  end

  # GET /posts/1
  def show
    @post = Post.find_by(id: params[:id])
    #@post.update(views: @post.views + 1) # update post view count
    #an enas user thelei na dei ena post poy exei diagrafei, ton kanw redirect sto index
    #px an vlepei to post kai ekeinh th stigmh o owner to diagrapsei, an kanei refresh, tha metavei sto index
    if @post.nil?
      #@pagy, @posts = pagy(Post.order(created_at: :desc), items: 5)
      #flash.now[:alert] = "Post was not found"
      #render "index"
      redirect_to posts_path, alert: "Post was not found"
    else
      #GEARED PAGINATION 
      #@comments = set_page_and_extract_portion_from @post.comments.where(parent_id: nil).includes(:user, :post, comments: :user).order(id: :desc), per_page: [5]
      
      #CURSOR-BASED PAGINATION COMMENTS
      #idios tropos me ta post me ta antistoixa views
      @cursor = params[:cursor]
      @comments = @post.comments
                                .where(parent_id: nil)  #kanw pagination mono sta top comments pou den exoun parent (Dhladh auta pou einai apanthsh se post kai oxi kapoio allo comment)
                                .where(@cursor ? ["id < ?", @cursor] : nil)
                                .includes(:user, :post, comments: :user) # improve performance, includes :user, kanw fetch olous tous users pou sysxetizontai me ta comments
                                .order(id: :desc).take(COMMENTS_PER_POST_PAGE)
      @next_cursor = @comments.last&.id
      @more_pages = @next_cursor.present? && @comments.count == COMMENTS_PER_POST_PAGE
      render "comments/scrollable_comment_list" if params[:cursor] 
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

    if current_user != @post.user
      respond_to do |format|
        format.turbo_stream { flash.now[:alert] = "You don't have the rights to edit this post." }
        format.html { redirect_to @post, alert: "You don't have the rights to edit this post." }
      end
    else
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
    end
  end

  # DELETE /posts/1
  def destroy
    #to xrhsimopoiousa otan edeixna ta buttons [edit, delete] se olous tous users kai oxi mono ston owner

    if current_user != @post.user
      respond_to do |format|
        flash.now[:alert] = "You don't have the rights to delete this post."
        format.turbo_stream do 
          render turbo_stream: [
            helpers.render_flash_messages
          ]
        end
        format.html { redirect_to @post, alert: "You don't have the rights to delete this post." }
      end
    else
      @post.destroy
      
      respond_to do |format|
        #destroy.turbo_frame.erb
        #deixnei to flash message mono ston current user
        format.turbo_stream { flash.now[:notice] = "Post #{@post.id} was successfully destroyed." }
        format.html { redirect_to posts_path, notice: "Post was successfully destroyed." }
      end
    end
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
