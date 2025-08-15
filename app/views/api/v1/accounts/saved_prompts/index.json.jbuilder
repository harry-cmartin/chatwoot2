json.array! @saved_prompts do |saved_prompt|
  json.id saved_prompt.id
  json.nome saved_prompt.nome
  json.conteudo saved_prompt.conteudo
  json.created_at saved_prompt.created_at
  json.updated_at saved_prompt.updated_at
end