module Forem
  module Admin
    class GroupsController < BaseController
      def index
        @groups = Group.all
      end

      def new
        @group = Group.new
      end

      def create
        @group = Group.new(params[:group])
        if @group.save
          flash[:notice] = t("forem.admin.group.created")
          redirect_to [:admin, @group]
        else
          flash[:alert] = t("forem.admin.group.not_created")
          render :new
        end
      end
      
      def update
        @group = Group.find(params[:id])
        if @group.update_attributes(params[:group])
          flash[:notice] = "Group Updated"
          redirect_to [:admin, @group]
        else
          flash[:alert] = "Group could not be updated"
          render :edit
        end
      end
      
      def edit
        @group = Group.find(params[:id])
      end
      
      def show
        @group = Group.find(params[:id])
      end

      def destroy
        @group = Group.find(params[:id])
        @group.destroy
        flash[:notice] = t("forem.admin.group.deleted")
        redirect_to admin_groups_path
      end
    end
  end
end
