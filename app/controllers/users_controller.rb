class UsersController < ApplicationController
  def show
    redirect_to new_user_session_path if current_user.nil?
    @last_workout = current_user.workouts.last
    # binding.pry
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
  end

  def destroy
  end

  def leaderboard
    @leaderboard = User.leaderboard
    render 'leaderboard'
  end
end
