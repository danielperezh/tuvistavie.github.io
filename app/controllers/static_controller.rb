class StaticController < ApplicationController
  def about
  end

  def not_found
    render_404
  end
end
