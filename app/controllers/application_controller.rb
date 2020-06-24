class ApplicationController < ActionController::Base
  include SessionsHelper

  private

    # ユーザーのログインを確認する
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = t('.please log in')
        redirect_to login_url
      end
    end

    def count_flash(search_result)
      flash.now[:success] = t('.search result count',search_result_count: search_result.count)
    end
end
