module Forem
  class PostsController < Forem::ApplicationController
    before_filter :authenticate_forem_user
    before_filter :find_topic
    before_filter :block_spammers, :only => [:new, :create]

    def new
      authorize! :reply, @topic
      @post = @topic.posts.build
      if params[:quote]
        @reply_to = @topic.posts.find(params[:reply_to_id])
        @post.text = view_context.forem_quote(@reply_to.text)
      end
    end

    def create
      authorize! :reply, @topic
      if @topic.locked?
        flash.alert = t("forem.post.not_created_topic_locked")
        redirect_to [@topic.forum, @topic] and return
      end
      @post = @topic.posts.build(params[:post])
      @post.user = forem_user
      if @post.save
        flash[:notice] = t("forem.post.created")
        redirect_to [@topic.forum, @topic]
      else
        params[:reply_to_id] = params[:post][:reply_to_id]
        flash.now.alert = t("forem.post.not_created")
        render :action => "new"
      end
    end

    def edit
      authorize! :edit_post, @topic.forum
      @post = Post.find(params[:id])
    end

    def update
      authorize! :edit_post, @topic.forum
      @post = Post.find(params[:id])
      if @post.owner_or_admin?(forem_user) and @post.update_attributes(params[:post])
        redirect_to [@topic.forum, @topic], :notice => t('edited', :scope => 'forem.post')
      else
        flash.now.alert = t("forem.post.not_edited")
        render :action => "edit"
      end
    end

    def destroy
      @post = @topic.posts.find(params[:id])
      if forem_user.forem_admin?
        @post.destroy
        if @post.topic.posts.count == 0
          @post.topic.destroy
          flash[:notice] = t("forem.post.deleted_with_topic")
          redirect_to [@topic.forum]
        else
          flash[:notice] = t("forem.post.deleted")
          redirect_to [@topic.forum, @topic]
        end
      else
        flash[:alert] = t("forem.post.cannot_delete")
        redirect_to [@topic.forum, @topic]
      end

    end
    
    def remove_attachment
      @post = Post.find(params[:id])
      
      if @post.owner_or_admin?(forem_user)
        if params[:file_name] == "file_one"
          @post.file_one = nil
        elsif params[:file_name] == "file_two"
          @post.file_two = nil
        elsif params[:file_name] == "file_three"
          @post.file_three = nil
        end
        
        if @post.save!
          redirect_to [@topic.forum, @topic], :notice => "File Removed Successfully"
        else
          redirect_to [@topic.forum, @topic], :notice => "There was a problem removing the file"
        end
        
      else 
        redirect_to [@topic.forum, @topic], :notice => "You are not allowed to remove this file"
      end

    end
    
    def send_attachment
      @post = Post.find(params[:id])
      
      path = ""
      
      if params[:file_name] == "file_one"
        path = @post.file_one.path
        # data = @post.file_one.s3_object.read
      elsif params[:file_name] == "file_two"
        path = @post.file_two.path
        # data = @post.file_two.s3_object.read
      elsif params[:file_name] == "file_three"
        path = @post.file_three.path
        # data = @post.file_one.s3_object.read
      end
      
      time_of_exipry = Time.now + 15.minutes
      url = AWS::S3::S3Object.url_for(path, 'Spaceport_Forum', :expires => time_of_exipry.to_i)
      
      redirect_to url
          
    end
    
    private

    def find_topic
      @topic = Forem::Topic.find(params[:topic_id])
    end

    def block_spammers
      if forem_user.forem_state == "spam"
        flash[:alert] = t('forem.general.flagged_for_spam') + ' ' + t('forem.general.cannot_create_post')
        redirect_to :back
      end
    end
  end
end
