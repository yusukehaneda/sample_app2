class StaticPagesController < ApplicationController

  def home
    #@micropost = current_user.microposts.build if logged_in?

    if logged_in?
      @micropost  = current_user.microposts.build
      search_result = current_user.feed.search(params[:keyword]) if params[:keyword]

        if search_result && !search_result.empty?
          @feed_items = search_result.paginate(page: params[:page])
          @highlight_keyword = params[:keyword]
          count_flash(search_result)
        else
          @feed_items = current_user.feed.paginate(page: params[:page])
          flash.now[:info] = t('.not hit search') if params[:keyword]
        end
    end
  end

  def help
  end

  def about
  end

  def contact
  end
end
