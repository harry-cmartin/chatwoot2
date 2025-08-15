<script setup>
import { ref, computed, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';
import { useStore } from 'vuex';
import { useRoute, useRouter } from 'vue-router';
import ResizableTextArea from 'shared/components/ResizableTextArea.vue';
import Avatar from 'dashboard/components/widgets/Avatar.vue';
import savedPromptsAPI from 'dashboard/api/savedPrompts';
import axios from 'axios';

const { t } = useI18n();
const store = useStore();
const route = useRoute();
const router = useRouter();

// Estado do chat
const prompt = ref('');
const message = ref('');
const messages = ref([]);
const isLoading = ref(false);
const showCompare = ref(false);

// Estado do chat de comparação
const comparePrompt = ref('');
const compareMessage = ref('');
const compareMessages = ref([]);
const isCompareLoading = ref(false);

// Estado do feedback
const saveSuccess = ref(false);
const saveError = ref('');
const isSaving = ref(false);

// Obtém o ID do usuário atual e da conta
const currentUserId = computed(() => store.getters.getCurrentUserID);
const accountId = computed(() => store.getters.getCurrentAccountId);

// Função para carregar prompt salvo
const loadSavedPrompt = async (promptId) => {
  try {
    const response = await savedPromptsAPI.show(promptId);
    prompt.value = response.data.conteudo || '';
  } catch (error) {
    console.error('Erro ao carregar prompt:', error);
  }
};

// Hook onMounted para carregar prompt se houver promptId na URL
onMounted(() => {
  const promptId = route.query.promptId;
  if (promptId) {
    loadSavedPrompt(promptId);
  }
});

// Função para enviar mensagem
const sendMessage = async (isCompareChat = false) => {
  // Determina quais variáveis usar com base no chat (principal ou comparação)
  const currentPrompt = isCompareChat ? comparePrompt : prompt;
  const currentMessage = isCompareChat ? compareMessage : message;
  const currentMessages = isCompareChat ? compareMessages : messages;
  const loadingState = isCompareChat ? isCompareLoading : isLoading;
  
  // Verifica se há uma mensagem para enviar
  if (!currentMessage.value.trim()) return;
  
  // Adiciona a mensagem do usuário ao chat
  const userMessage = {
    content: currentMessage.value,
    sender: 'user',
    timestamp: new Date().toISOString(),
  };
  
  currentMessages.value.push(userMessage);
  
  // Limpa o campo de mensagem
  const messageToSend = currentMessage.value;
  currentMessage.value = '';
  
  try {
    // Define o estado de carregamento
    loadingState.value = true;
    
    // Cria o sessionId com base no ID do usuário e se é chat de comparação
    const sessionId = isCompareChat 
      ? `${currentUserId.value}_compare` 
      : currentUserId.value;
    
    // Envia a requisição para a API
    const response = await axios.post('https://teste.valparaiso.pro/webhook-test/enchat', {
      prompt: currentPrompt.value,
      message: messageToSend,
      sessionId: sessionId
    });
    
    // Adiciona a resposta da IA ao chat
    currentMessages.value.push({
      content: response.data.resposta || response.data.text || 'Sem resposta',
      sender: 'assistant',
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    console.error('Erro ao enviar mensagem:', error);
    // Adiciona mensagem de erro ao chat
    currentMessages.value.push({
      content: 'Ocorreu um erro ao processar sua mensagem.',
      sender: 'assistant',
      timestamp: new Date().toISOString(),
    });
  } finally {
    // Finaliza o estado de carregamento
    loadingState.value = false;
  }
};

// Função para alternar a visualização de comparação
const toggleCompare = () => {
  showCompare.value = !showCompare.value;
};

// Função para formatar mensagens
const getMessageStyle = (sender) => {
  return sender === 'user' 
    ? 'bg-n-strong text-n-white self-end' 
    : 'bg-n-solid-iris text-n-slate-12 self-start';
};

// Função para obter o nome do avatar
const getAvatarName = (sender) => {
  return sender === 'user' ? 'Você' : 'IA';
};

// Função para salvar prompt
const savePrompt = async (isCompareChat = false) => {
  const currentPrompt = isCompareChat ? comparePrompt : prompt;
  
  if (!currentPrompt.value.trim()) {
    saveError.value = 'Digite um prompt antes de salvar';
    setTimeout(() => {
      saveError.value = '';
    }, 3000);
    return;
  }
  
  try {
    isSaving.value = true;
    saveError.value = '';
    saveSuccess.value = false;
    
    const promptId = route.query.promptId;
    
    if (promptId) {
      // Atualiza prompt existente
      await savedPromptsAPI.update(promptId, {
        saved_prompt: {
          conteudo: currentPrompt.value
        }
      });
    } else {
      // Cria novo prompt (não deveria acontecer nesta página, mas como fallback)
      await savedPromptsAPI.create({
        saved_prompt: {
          nome: 'Novo Prompt',
          conteudo: currentPrompt.value
        }
      });
    }
    
    saveSuccess.value = true;
    setTimeout(() => {
      saveSuccess.value = false;
    }, 3000);
  } catch (error) {
    console.error('Erro ao salvar prompt:', error);
    saveError.value = 'Erro ao salvar prompt';
    setTimeout(() => {
      saveError.value = '';
    }, 3000);
  } finally {
    isSaving.value = false;
  }
};

// Função para voltar à lista de prompts
const goBackToList = () => {
  router.push({
    name: 'saved_prompts_list',
    params: { accountId: accountId.value }
  });
};
</script>

<template>
  <div class="w-full h-full flex flex-col p-4 bg-n-background">
    <!-- Cabeçalho com botões de navegação e ações -->
    <div class="flex justify-between items-center mb-4">
      <div class="flex items-center gap-3">
        <button
          @click="goBackToList"
          class="px-3 py-1 bg-n-weak text-n-slate-12 rounded-md text-sm hover:brightness-110 transition-all"
        >
          ← Voltar para Lista
        </button>
        <Avatar :username="'AI Assistant'" :size="24" />
        <span class="ml-2 font-medium text-n-slate-12">
          AI Assistant
        </span>
      </div>
      <div class="flex items-center gap-2">
        <button
          @click="savePrompt(false)"
          :disabled="isSaving"
          class="px-3 py-1 bg-n-brand text-n-white rounded-md text-sm hover:brightness-110 transition-all disabled:opacity-50"
        >
          {{ isSaving ? 'Salvando...' : 'Salvar Prompt' }}
        </button>
        <button 
          v-if="!showCompare" 
          class="px-3 py-1 bg-n-strong text-n-white rounded-md text-sm hover:brightness-110 transition-all"
          @click="toggleCompare"
        >
          Compare AI
        </button>
        <button 
          v-else 
          class="px-3 py-1 bg-n-ruby-8 text-n-white rounded-md text-sm hover:brightness-110 transition-all"
          @click="toggleCompare"
        >
          Fechar Compare
        </button>
      </div>
    </div>
    
    <!-- Feedback de salvamento -->
    <div v-if="saveSuccess || saveError" class="mb-4">
      <div v-if="saveSuccess" class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative">
        ✅ Prompt salvo com sucesso!
      </div>
      <div v-if="saveError" class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative">
        ❌ {{ saveError }}
      </div>
    </div>
    
    <!-- Container principal -->
    <div class="flex flex-1 gap-4 overflow-hidden">
      <!-- Chat principal -->
      <div class="flex flex-col flex-1 h-full bg-white dark:bg-n-solid-2 rounded-lg shadow-sm overflow-hidden">
        <!-- Campo de prompt -->
        <div class="p-4 border-b border-n-weak">
          <label class="block text-sm font-medium text-n-slate-12 mb-1">Prompt do Sistema:</label>
          <ResizableTextArea
            v-model="prompt"
            :rows="2"
            placeholder="Digite o prompt do sistema (Obrigatorio)"
            class="w-full border border-n-weak rounded-md p-2 text-sm"
          />
        </div>
        
        <!-- Área de mensagens -->
        <div class="flex-1 p-4 overflow-y-auto space-y-4">
          <div v-if="messages.length === 0" class="flex flex-col items-center justify-center h-full">
            <Avatar :username="'AI'" :size="48" />
            <p class="mt-4 text-n-slate-11">Comece uma conversa com a IA</p>
          </div>
          
          <div 
            v-for="(message, index) in messages" 
            :key="index"
            class="flex items-start gap-2"
            :class="message.sender === 'user' ? 'justify-end' : 'justify-start'"
          >
            <Avatar 
              v-if="message.sender !== 'user'" 
              :username="getAvatarName(message.sender)" 
              :size="24" 
            />
            <div 
              class="max-w-[80%] rounded-lg p-3 text-sm"
              :class="getMessageStyle(message.sender)"
            >
              <div class="break-words">{{ message.content }}</div>
            </div>
            <Avatar 
              v-if="message.sender === 'user'" 
              :username="getAvatarName(message.sender)" 
              :size="24" 
            />
          </div>
          
          <div v-if="isLoading" class="flex items-start gap-2 justify-start">
            <Avatar :username="'IA'" :size="24" />
            <div class="max-w-sm rounded-lg p-3 text-sm bg-n-solid-iris text-n-slate-12">
              <div class="flex gap-1">
                <div class="w-2 h-2 rounded-full bg-n-iris-10 animate-bounce" />
                <div class="w-2 h-2 rounded-full bg-n-iris-10 animate-bounce [animation-delay:0.2s]" />
                <div class="w-2 h-2 rounded-full bg-n-iris-10 animate-bounce [animation-delay:0.4s]" />
              </div>
            </div>
          </div>
        </div>
        
        <!-- Campo de mensagem -->
        <div class="p-4 border-t border-n-weak">
          <label class="block text-sm font-medium text-n-slate-12 mb-1">Mensagem:</label>
          <div class="flex items-center">
            <ResizableTextArea
              v-model="message"
              :rows="1"
              placeholder="Digite sua mensagem..."
              class="flex-1 border border-n-weak rounded-md p-2 text-sm"
              @keyup.enter="sendMessage(false)"
            />
            <button 
              class="ml-2 p-2 bg-n-strong text-n-white rounded-md"
              :disabled="!message.trim()"
              @click="sendMessage(false)"
            >
              ➤
            </button>
          </div>
        </div>
      </div>
      
      <!-- Chat de comparação (quando ativado) -->
      <div v-if="showCompare" class="flex flex-col flex-1 h-full bg-white dark:bg-n-solid-2 rounded-lg shadow-sm overflow-hidden">
        <!-- Campo de prompt -->
        <div class="p-4 border-b border-n-weak">
          <div class="flex justify-between items-center mb-1">
            <label class="block text-sm font-medium text-n-slate-12">Prompt do Sistema:</label>
            <button
              @click="savePrompt(true)"
              :disabled="isSaving"
              class="px-3 py-1 bg-n-brand text-n-white rounded-md text-sm hover:brightness-110 transition-all disabled:opacity-50"
            >
              {{ isSaving ? 'Salvando...' : 'Salvar Prompt' }}
            </button>
          </div>
          <ResizableTextArea
            v-model="comparePrompt"
            :rows="2"
            placeholder="Digite o prompt do sistema (opcional)"
            class="w-full border border-n-weak rounded-md p-2 text-sm"
          />
        </div>
        
        <!-- Área de mensagens -->
        <div class="flex-1 p-4 overflow-y-auto space-y-4">
          <div v-if="compareMessages.length === 0" class="flex flex-col items-center justify-center h-full">
            <Avatar :username="'AI'" :size="48" />
            <p class="mt-4 text-n-slate-11">Comece uma conversa com a IA</p>
          </div>
          
          <div 
            v-for="(message, index) in compareMessages" 
            :key="index"
            class="flex items-start gap-2"
            :class="message.sender === 'user' ? 'justify-end' : 'justify-start'"
          >
            <Avatar 
              v-if="message.sender !== 'user'" 
              :username="getAvatarName(message.sender)" 
              :size="24" 
            />
            <div 
              class="max-w-[80%] rounded-lg p-3 text-sm"
              :class="getMessageStyle(message.sender)"
            >
              <div class="break-words">{{ message.content }}</div>
            </div>
            <Avatar 
              v-if="message.sender === 'user'" 
              :username="getAvatarName(message.sender)" 
              :size="24" 
            />
          </div>
          
          <div v-if="isCompareLoading" class="flex items-start gap-2 justify-start">
            <Avatar :username="'IA'" :size="24" />
            <div class="max-w-sm rounded-lg p-3 text-sm bg-n-solid-iris text-n-slate-12">
              <div class="flex gap-1">
                <div class="w-2 h-2 rounded-full bg-n-iris-10 animate-bounce" />
                <div class="w-2 h-2 rounded-full bg-n-iris-10 animate-bounce [animation-delay:0.2s]" />
                <div class="w-2 h-2 rounded-full bg-n-iris-10 animate-bounce [animation-delay:0.4s]" />
              </div>
            </div>
          </div>
        </div>
        
        <!-- Campo de mensagem -->
        <div class="p-4 border-t border-n-weak">
          <label class="block text-sm font-medium text-n-slate-12 mb-1">Mensagem:</label>
          <div class="flex items-center">
            <ResizableTextArea
              v-model="compareMessage"
              :rows="1"
              placeholder="Digite sua mensagem..."
              class="flex-1 border border-n-weak rounded-md p-2 text-sm"
              @keyup.enter="sendMessage(true)"
            />
            <button 
              class="ml-2 p-2 bg-n-strong text-n-white rounded-md"
              :disabled="!compareMessage.trim()"
              @click="sendMessage(true)"
            >
              ➤
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>