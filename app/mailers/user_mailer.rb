class UserMailer < ApplicationMailer

  #通常のコントローラーみたいにデフォルトでviewが呼び出されるわけではない
  def account_activation(user)
    @user = user
    mail to: user.email, 
    subject: "Account activation"
    # => return: mail object (text/html)
    #   example: mail.deliver
  end

  # @user.send_reset_email
  # self = @user
  # UserMailer.password_reset(self).deliver_now
  def password_reset(user)
    @user = user
    mail to: user.email, subject: "Password reset"
  end
end
