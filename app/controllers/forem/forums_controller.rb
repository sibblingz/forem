module Forem
  class ForumsController < Forem::ApplicationController
    # load_and_authorize_resource :only => :show
    helper 'forem/topics'

    def index
      @categories = Forem::Category.order("forem_categories.order ASC")
    end

    def show
      @forum = Forem::Forum.find(params[:id])
      authorize! :read, @forum
      @topics = if forem_admin_or_moderator?(@forum)
        @forum.topics
      else
        @forum.topics.visible.approved_or_pending_review_for(forem_user)
      end
      
      # working topic sort
      
      if params[:sort]
        @topics = @topics.order(params[:sort] + ' ' + params[:direction].upcase).page(params[:page]).per(20)
      else
        @topics = @topics.by_pinned_or_most_recent_post.page(params[:page]).per(20)
      end

      respond_to do |format|
        format.html
        format.atom { render :layout => false }
      end
    end
  end
end
