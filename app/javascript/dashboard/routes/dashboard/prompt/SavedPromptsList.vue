<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useStore } from 'vuex';
import savedPromptsAPI from 'dashboard/api/savedPrompts';
import Avatar from 'dashboard/components/widgets/Avatar.vue';

const router = useRouter();
const store = useStore();

const savedPrompts = ref([]);
const isLoading = ref(false);
const newPromptName = ref('');
const showCreateForm = ref(false);

const accountId = computed(() => store.getters.getCurrentAccountId);

const fetchSavedPrompts = async () => {
  try {
    isLoading.value = true;
    const response = await savedPromptsAPI.get();
    savedPrompts.value = response.data;
  } catch (error) {
    console.error('Erro ao carregar prompts salvos:', error);
  } finally {
    isLoading.value = false;
  }
};

const createNewPrompt = async () => {
  if (!newPromptName.value.trim()) return;
  
  try {
    const response = await savedPromptsAPI.create({
      saved_prompt: {
        nome: newPromptName.value,
        conteudo: 'Meu prompt ...'
      }
    });
    
    // Limpa o formulário
    showCreateForm.value = false;
    newPromptName.value = '';
    
    // Recarrega a lista de prompts para mostrar o novo prompt
    await fetchSavedPrompts();
  } catch (error) {
    console.error('Erro ao criar prompt:', error);
  }
};

const deletePrompt = async (promptId) => {
  if (!confirm('Tem certeza que deseja deletar este prompt?')) return;
  
  try {
    await savedPromptsAPI.delete(promptId);
    await fetchSavedPrompts();
  } catch (error) {
    console.error('Erro ao deletar prompt:', error);
  }
};

const openPrompt = (promptId) => {
  router.push({
    name: 'prompt_page',
    params: { accountId: accountId.value },
    query: { promptId }
  });
};

const goToNewPrompt = () => {
  router.push({
    name: 'prompt_page',
    params: { accountId: accountId.value }
  });
};

onMounted(() => {
  fetchSavedPrompts();
});
</script>

<template>
  <div class="w-full h-full flex flex-col p-4 bg-n-background">
    <!-- Cabeçalho -->
    <div class="flex justify-between items-center mb-4">
      <div class="flex items-center">
        <Avatar :username="'Prompts'" :size="24" />
        <span class="ml-2 font-medium text-n-slate-12">Prompts Salvos</span>
      </div>
      <div class="flex items-center gap-2">
        <button
          @click="showCreateForm = !showCreateForm"
          class="px-3 py-1 bg-n-brand text-n-white rounded-md text-sm hover:brightness-110 transition-all"
        >
          {{ showCreateForm ? 'Cancelar' : 'Criar Novo Prompt' }}
        </button>
      </div>
    </div>
    
    <!-- Formulário de criação -->
    <div v-if="showCreateForm" class="mb-4 p-4 bg-white dark:bg-n-solid-2 rounded-lg shadow-sm border border-n-weak">
      <h3 class="text-lg font-medium text-n-slate-12 mb-2">Criar Novo Prompt</h3>
      <p class="text-sm text-n-slate-11 mb-4">Digite um nome para o prompt. Após criar, você será redirecionado para adicionar o conteúdo.</p>
      <div class="flex gap-2">
        <input
          v-model="newPromptName"
          type="text"
          placeholder="Ex: Assistente de Marketing, Revisor de Texto..."
          class="flex-1 px-3 py-2 border border-n-weak rounded-md text-sm focus:border-n-brand focus:outline-none"
          @keyup.enter="createNewPrompt"
        />
        <button
          @click="createNewPrompt"
          :disabled="!newPromptName.trim()"
          class="px-4 py-2 bg-n-brand text-n-white rounded-md text-sm hover:brightness-110 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Criar Prompt
        </button>
      </div>
    </div>

    <!-- Container principal -->
    <div class="flex-1 bg-white dark:bg-n-solid-2 rounded-lg shadow-sm overflow-hidden">
      <div v-if="isLoading" class="flex items-center justify-center h-32">
        <div class="flex gap-1">
          <div class="w-2 h-2 rounded-full bg-n-iris-10 animate-bounce" />
          <div class="w-2 h-2 rounded-full bg-n-iris-10 animate-bounce [animation-delay:0.2s]" />
          <div class="w-2 h-2 rounded-full bg-n-iris-10 animate-bounce [animation-delay:0.4s]" />
        </div>
      </div>
      
      <div v-else-if="savedPrompts.length === 0" class="flex flex-col items-center justify-center h-full text-n-slate-11">
        <Avatar :username="'Prompts'" :size="48" />
        <p class="mt-4 text-lg font-medium">Nenhum prompt salvo</p>
        <p class="text-sm">Crie seu primeiro prompt para começar</p>
      </div>
      
      <div v-else class="p-4 overflow-y-auto h-full">
        <div class="space-y-4">
          <div
            v-for="prompt in savedPrompts"
            :key="prompt.id"
            class="flex items-start gap-3 p-4 border border-n-weak rounded-lg hover:bg-n-slate-2 transition-colors cursor-pointer"
            @click="openPrompt(prompt.id)"
          >
            <Avatar :username="prompt.nome" :size="32" />
            <div class="flex-1">
              <h3 class="font-medium text-n-slate-12">{{ prompt.nome }}</h3>
              <p class="text-sm text-n-slate-11 mt-1 break-words">
                <span v-if="prompt.conteudo && prompt.conteudo.trim() && prompt.conteudo.trim() !== 'Clique para adicionar conteúdo ao prompt'">
                  {{ prompt.conteudo.substring(0, 100) }}{{ prompt.conteudo.length > 100 ? '...' : '' }}
                </span>
                <span v-else class="italic text-n-slate-9">
                  Clique para adicionar conteúdo ao prompt
                </span>
              </p>
              <p class="text-xs text-n-slate-10 mt-2">
                Criado em {{ new Date(prompt.created_at).toLocaleDateString('pt-BR') }}
              </p>
            </div>
            <div class="flex items-center gap-2">
              <button
                @click.stop="deletePrompt(prompt.id)"
                class="p-2 text-red-600 hover:text-red-700 hover:bg-red-50 rounded-md transition-colors"
                title="Deletar prompt"
              >
                ✕
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>