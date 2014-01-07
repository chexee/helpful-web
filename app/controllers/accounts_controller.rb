class AccountsController < ApplicationController
  before_action :authenticate_user!, only: [:edit, :update]

  def new
    @account = Account.new
    @new_account_user = User.new
    @person = Person.new
  end

  def create
    user_params = params.require(:user).permit(:email, :password, :password_confirmation)
    account_params = params.require(:account).permit(:name)
    person_params = params.require(:person).permit(:name)

    @new_account_user = User.new user_params
    @account = Account.new account_params
    @person = Person.new person_params

    @person.email = @new_account_user.email
    @person.account = @account

    @account.new_account_user = @new_account_user
    @new_account_user.person = @person

    if @new_account_user.valid? && @account.valid? && @person.valid? && @account.save

      sign_in(@new_account_user)

      Analytics.identify(
          user_id: @new_account_user.id,
          traits: { email: @new_account_user.email, account_id: @account.id })
      Analytics.track(
          user_id: @new_account_user.id,
          event: 'Signed Up')

      redirect_to root_path, notice: 'You have successfully signed up!  Try logging in!'
    else
      render 'new'
    end
  end

  def edit
    @account = current_user.primary_owned_account
    @user = @account.users.new
  end

  def update
    @account = current_user.primary_owned_account

    respond_to do |format|
      if @account.update_attributes(account_params)
        format.html { redirect_to edit_account_url, notice: "Account settings updated" }
      else
        format.html { render 'edit' }
      end
    end
  end

  private

  def account_params
    params.require(:account).permit(:name, :website_url, :webhook_url)
  end

end
