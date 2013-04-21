class AdminsController < ApplicationController
  before_filter :authenticate_admin!

  def edit
    @admin = current_admin
  end

  def update
    @admin = Admin.find(params[:id])
    if @admin.update_attributes(params[:admin])
      redirect_to root_path
    else
      render :action => "edit"
    end
  end

end
