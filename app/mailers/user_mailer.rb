class UserMailer < ApplicationMailer

  #通常のコントローラーみたいにデフォルトでviewが呼び出されるわけではない
  def account_activation(user)
    @user = user
    mail to: user.email, 
    subject: "Account activation"
    # => return: mail object (text/html)
    #   example: mail.deliver
  end

  def password_reset
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
