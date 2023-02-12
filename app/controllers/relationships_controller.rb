class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
    followed_user = User.find(params[:followed_id])
    current_user.follow(followed_user)
    redirect_to followed_user
  end

  def destroy
    followed_user = Relationship.find(params[:id]).followed
    current_user.unfollow(followed_user)
    redirect_to followed_user, status: :see_other
  end
end
