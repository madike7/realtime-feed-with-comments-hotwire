class CommentsController < ApplicationController
  include ActionView::RecordIdentifier
  #before_action :is_author?, only: [:edit, :update]
  
  def create
    #create neo comment gia to post apo ton current_user
    @comment = current_user.comments.new(comment_params) # pernaw kateutheian to id tou current_user
    
    if @comment.post.nil? #an to post exei diagrafei kai o user einai sto show h epixeirhsei na paei sto url tou, kanw redirect
      redirect_to posts_path, alert: "Post was not found"
    else
      respond_to do |format|
        if @comment.save
          flash.now[:notice] = "Comment #{@comment.id} was successfully created."
          format.turbo_stream do
            render turbo_stream: [
              # to neo comment ginetai kateutheian broadcast apo to model comment.rb se olous tous users
              # edw kanw render to flash message mono ston user pou kanei to comment
              helpers.render_flash_messages 
            ]
          end
          format.html { redirect_to @comment.post, notice: 'Comment was successfully created.' }
        else
          flash.now[:alert] = 'Something went wrong...'
          format.turbo_stream do
            render turbo_stream: [
              # kanw render to flash message ston user
              helpers.render_flash_messages
            ]
          end
        end
      end
    end
  end

  def show
    #@comment = current_user.comments.find(params[:id]) # otan eixa to is_author?
    @comment = Comment.find(params[:id]) # oloi oi users mporoun na doun to show page enos comment
  end

  def edit
    @comment = Comment.find(params[:id])
  end
  
  def update
    # update to comment tou post apo ton current_user
    #@comment = current_user.comments.find(params[:id]) #mono o comment owner mporei na kanei update ena comment
    @comment = Comment.find(params[:id])
    #to xrhsimopoiousa otan edeixna ta buttons [edit, delete] se olous tous users kai oxi mono ston owner
    if current_user != @comment.user
      respond_to do |format|
        format.turbo_stream { flash.now[:alert] = "You don't have the rights to edit this comment." }
        format.html { redirect_to @comment, alert: "You don't have the rights to edit this comment." }
      end
    else
      if @comment.update(comment_params)
        respond_to do |format|
          # update.turbo_stream.erb
          # to updated comment ginetai kateutheian broadcast apo to model comment.rb se olous tous users
          format.turbo_stream { flash.now[:notice] = "Comment #{@comment.id} was successfully updated." }
          format.html { redirect_to @comment }
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def destroy
    # delete to comment tou post apo ton current_user
    #@comment = current_user.comments.find(params[:id]) otan eixa to is_author?
    @comment = Comment.find(params[:id])

    #to xrhsimopoiousa otan edeixna ta buttons [edit, delete] se olous tous users kai oxi mono ston owner
    if current_user != @comment.user
      respond_to do |format|
        format.turbo_stream { flash.now[:alert] = "You don't have the rights to delete this comment." }
        format.html { redirect_to @comment.post, alert: "You don't have the rights to delete this comment." }
      end
    else
      @comment.destroy

      respond_to do |format|
        # destroy.turbo_stream.erb
        # to comment ginetai removed gia olous tous users mesa tou broadcast apo to comment.rb
        format.turbo_stream { flash.now[:notice] = "Comment #{@comment.id} was successfully deleted." }
        format.html { redirect_to @comment.post }
      end
    end
  end
  
  private

  def comment_params
    params
      .require(:comment)
      .permit(:body, :parent_id)  # permits parent_id gia na to pernaw sti forma tou comment
      .merge(post_id: params[:post_id]) # to post_comments_path periexei tis plhrofories tou post sto opoio dhmiourgw to comment,
                                        # opote kanw merge tis params pou pernaw edw, wste na periexoun to post_id apo to post params
  end

  # mono o comment owner mporei na kanei edit kai delete to comment tou
  # an prospathisei na kanei edit kapoios allos, ton kanw redirect sto post tou comment kai kanw render to flash message
  def is_author?
    @comment = Comment.find(params[:id])
    redirect_to @comment.post, alert: "You don't have the rights to edit or delete this comment." unless @comment.user == current_user
  end
end
