class UserSuggestionsController < ApplicationController
  before_action :set_user_suggestion, only: [:destroy]

  def index
    @user_suggestions = UserSuggestion.all
  end

  def create
    @user_suggestion = UserSuggestion.new(user_suggestion_params)
    respond_to do |format|
      if @user_suggestion.save
        format.json { render nothing: true, status: :created }
      else
        format.json { render json: @user_suggestion.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user_suggestion.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    def set_user_suggestion
      @user_suggestion = UserSuggestion.find(params[:id])
    end

    def user_suggestion_params
      params.require(:user_suggestion).permit(:name, :email, :phone, :group, :suggestion)
    end
end
