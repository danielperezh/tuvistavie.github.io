class AdminsController < ApplicationController
  before_filter :authenticate_admin!

  def edit
    @admin = current_admin
  end

  def update
    @admin = Admin.find(params[:id])
    if @admin.update_attributes(admin_params)
      redirect_to about_path
    else
      render action: 'edit'
    end
  end

  private

  def admin_params
    params.require(:admin).permit(
      :email, :password, :password_confirmation, :remember_me, :profile,
      :long_profile, :small_picture, :large_picture, :first_name, :last_name,
      :nickname, :work_place, :work_position, :work_url
    )
  end
end
