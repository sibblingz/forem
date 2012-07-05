module Forem
  class CategoriesController < ApplicationController
    # load_and_authorize_resource

    def show
      @category = Category.find(params[:id])
      authorize! :read, @category
    end
  end
end
