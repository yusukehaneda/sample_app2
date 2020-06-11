module SessionsHelper
  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end

  # ユーザーのセッションを永続的にする
  def remember(user)
    # この下のrememberはapp/models/user.rbで設定したrememberメソッド
    user.remember
     #signedは暗号化
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
    #ここのremember_tokenはuser.rememberを実行したから使える
  end

    # 現在ログイン中のユーザーを返す (いる場合)
  def current_user
    # DBへの問い合わせの数を可能な限り小さくしたい
    if (user_id = session[:user_id]) #user_id にsessionを入れてその値がtrueかどうか。この=は代入式
       #user_idがある = セッションがある　ならば
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id]) #user_idを復号化
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end

    #if session[:user_id]
        #User.find_by(id: session[:user_id])
      #@current_user ||= User.find_by(id: session[:user_id])
        #@current_user = @current_user or User.find_by...
        #@current_userがnil or falseならfind_byを実行する
           #if @current_user.nil?
           #   @current_user = User.find_by(id: session[:user_id])
           #   return @current_user
           #else
           #   return @current_user
           #end
           # current_userはいろいろなところで呼びだされるので、インスタンス変数にする
    #end
  end


  # 渡されたユーザーがカレントユーザーであればtrueを返す
  # nilガードしつつuser がcurrent_userかチェックする。userがnilでなければ、&&の右を実行。
  def current_user?(user)
    user && user == current_user
  end


  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    #current_userがnilではないですか？nilではないならtrue.nilならfalse
    !current_user.nil? 
  end

  # 永続的セッションを破棄する
  def forget(user)
    user.forget #remember_digestを削除
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # 現在のユーザーをログアウトする
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  # 記憶したURL (もしくはデフォルト値) にリダイレクト
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # アクセスしようとしたURLを覚えておく
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end

end
