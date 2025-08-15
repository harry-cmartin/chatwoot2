class Api::V1::Accounts::SavedPromptsController < Api::V1::Accounts::BaseController
  before_action :set_saved_prompt, only: [:show, :update, :destroy]

  def index
    @saved_prompts = Current.user.saved_prompts.order(created_at: :desc)
  end

  def show; end

  def create
    @saved_prompt = Current.user.saved_prompts.build(saved_prompt_params)
    
    if @saved_prompt.save
      render json: @saved_prompt, status: :created
    else
      render json: { errors: @saved_prompt.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @saved_prompt.update(saved_prompt_params)
      render json: @saved_prompt
    else
      render json: { errors: @saved_prompt.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @saved_prompt.destroy
    head :no_content
  end

  private

  def set_saved_prompt
    @saved_prompt = Current.user.saved_prompts.find(params[:id])
  end

  def saved_prompt_params
    params.require(:saved_prompt).permit(:nome, :conteudo)
  end
end