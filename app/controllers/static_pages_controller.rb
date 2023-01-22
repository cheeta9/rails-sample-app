class StaticPagesController < ApplicationController
  before_action :logged_in_user, only: %i[about contact]

  def home; end

  def help; end

  def about; end

  def contact; end
end
