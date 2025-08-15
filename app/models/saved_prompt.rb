# == Schema Information
#
# Table name: saved_prompts
#
#  id         :uuid             not null, primary key
#  nome       :text             not null
#  conteudo   :text             not null
#  user_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_saved_prompts_on_user_id  (user_id)
#
class SavedPrompt < ApplicationRecord
  belongs_to :user
  
  validates :nome, presence: true
  validates :conteudo, presence: true
  validates :user_id, presence: true
end