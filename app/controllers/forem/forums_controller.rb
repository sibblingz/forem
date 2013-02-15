module Forem
  class ForumsController < Forem::ApplicationController
    # load_and_authorize_resource :only => :show
    helper 'forem/topics'

    def index
      # count how many are visible to the user, and remember the first visible one so we can redirect to it if there is only one
      forums = Forem::Forum.all
      num_visible_forums = 0
      first_visible_forum = nil
      forums.each do |forum|
        if can? :read, forum
          if num_visible_forums == 0
            first_visible_forum = forum
          end
          num_visible_forums += 1
        end
      end
      if num_visible_forums == 1
        redirect_to first_visible_forum
        return
      end

      @categories = Forem::Category.order("forem_categories.position ASC")
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
