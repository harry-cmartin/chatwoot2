# Modificações do Projeto

## Arquivos Modificados

- `app/javascript/dashboard/components-next/sidebar/Sidebar.vue`
- `app/javascript/dashboard/i18n/locale/en/index.js`
- `app/javascript/dashboard/routes/dashboard/dashboard.routes.js`
- `app/javascript/widget/helpers/utils.js`
- `app/models/user.rb`
- `config/routes.rb`
- `db/schema.rb`
- `docker-compose.yaml`

## Arquivos Deletados

- `vendor/db/sentiment-analysis.onnx`

## Novos Arquivos

### Sistema de Prompts Salvos
- `app/controllers/api/v1/accounts/saved_prompts_controller.rb`
- `app/javascript/dashboard/api/savedPrompts.js`
- `app/models/saved_prompt.rb`
- `app/javascript/dashboard/routes/dashboard/prompt/prompt.routes.js`
- `app/javascript/dashboard/routes/dashboard/prompt/PromptPage.vue`
- `app/javascript/dashboard/routes/dashboard/prompt/SavedPromptsList.vue`
- `app/views/api/v1/accounts/saved_prompts/`
- `db/migrate/20250115000001_create_saved_prompts.rb`

### Sistema RAG
- `app/javascript/dashboard/routes/dashboard/rag/rag.routes.js`
- `app/javascript/dashboard/routes/dashboard/rag/RagPage.vue`
- `app/javascript/dashboard/routes/dashboard/rag/DocumentUpload.vue`
- `app/javascript/dashboard/routes/dashboard/rag/CompareDocumentUpload.vue`
- `app/javascript/dashboard/routes/dashboard/rag/DocumentList.vue`
- `app/javascript/dashboard/routes/dashboard/rag/DocumentSelector.vue`

### Internacionalização
- `app/javascript/dashboard/i18n/locale/en/prompt.json`
- `app/javascript/dashboard/i18n/locale/en/rag.json`

### Outros
- `.pnpm-store/`
- `.trae/`
- `.vercel/`
- `webhooks.http`

## Principais Funcionalidades Adicionadas

1. **Sistema de Prompts Salvos** - Gerenciamento de prompts personalizados
2. **Sistema RAG** - Upload e comparação de documentos para IA
3. **Nova tabela no banco** - `saved_prompts` para armazenar prompts
4. **APIs RESTful** - Endpoints para gerenciar prompts
5. **Interface Vue.js** - Páginas para interação com os novos sistemas