<script setup>
import { ref, computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { useStore } from 'vuex';
import ResizableTextArea from 'shared/components/ResizableTextArea.vue';
import Avatar from 'dashboard/components/widgets/Avatar.vue';
import DocumentList from './DocumentList.vue';
import DocumentUpload from './DocumentUpload.vue';
import DocumentSelector from './DocumentSelector.vue';
import CompareDocumentUpload from './CompareDocumentUpload.vue';
import axios from 'axios';

const { t } = useI18n();
const store = useStore();

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
const showDocumentList = ref(false);
const showDocumentUpload = ref(false);
const showDocumentSelector = ref(false);
const selectedDocumentsForComparison = ref([]);
const showCompareDocumentUpload = ref(false);

// Obtém o ID do usuário atual
const currentUserId = computed(() => store.getters.getCurrentUserID);

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
    
    // Envia a requisição para a API - usa webhook específico para chat de comparação
    const webhookUrl = isCompareChat 
      ? 'https://anzol.encha.top/webhook/48c816a2-ac46-4a94-8f19-01331ae3d2ef'
      : 'https://anzol.encha.top/webhook/5cbbd267-7ae4-49fd-8324-fcd67ab2a108';
    
    const response = await axios.post(webhookUrl, {
      user: {
        id: currentUserId.value
      },
      Message: {
        Content: messageToSend
      },
      Prompt: {
        Content: currentPrompt.value
      }
    });
    
    // Adiciona a resposta da IA ao chat
    currentMessages.value.push({
      content: response.data[0].output || 'Sem resposta',
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
  if (showCompare.value) {
    // Se já está mostrando comparação, fecha
    showCompare.value = false;
    selectedDocumentsForComparison.value = [];
  } else {
    // Se não está mostrando, abre o seletor de documentos
    showDocumentSelector.value = true;
  }
};

const toggleDocumentList = () => {
  showDocumentList.value = !showDocumentList.value;
};

const closeDocumentList = () => {
  showDocumentList.value = false;
};

const toggleDocumentUpload = () => {
  showDocumentUpload.value = !showDocumentUpload.value;
};

const closeDocumentUpload = () => {
  showDocumentUpload.value = false;
};

const handleDocumentUploaded = () => {
  // Atualizar lista de documentos se estiver visível
  if (showDocumentList.value) {
    // Força atualização da lista
    closeDocumentList();
    setTimeout(() => {
      showDocumentList.value = true;
    }, 100);
  }
};

const closeDocumentSelector = () => {
  showDocumentSelector.value = false;
};

const handleDocumentsSelected = (documents) => {
  selectedDocumentsForComparison.value = documents;
  showDocumentSelector.value = false;
  showCompare.value = true;
};

const toggleCompareDocumentUpload = () => {
  showCompareDocumentUpload.value = !showCompareDocumentUpload.value;
};

const closeCompareDocumentUpload = () => {
  showCompareDocumentUpload.value = false;
};

const handleCompareDocumentUploaded = () => {
  // Pode adicionar lógica adicional aqui se necessário
  console.log('Documento enviado para comparação');
};

const handleReplaceAllDocuments = async () => {
  const confirmed = confirm('Tem certeza que deseja substituir todos os documentos? Esta ação não pode ser desfeita.');
  
  if (confirmed) {
    try {
      await axios.post('https://anzol.encha.top/webhook/0240cb84-b93c-4f50-a04e-d5875e29654d', {
        user: {
          id: currentUserId.value.toString()
        },
        replaceall: true
      }, {
        headers: {
          'Content-Type': 'application/json'
        }
      });
      
      alert('Documentos substituídos com sucesso!');
    } catch (error) {
      console.error('Erro ao substituir documentos:', error);
      alert('Erro ao substituir documentos. Tente novamente.');
    }
  }
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
</script>

<template>
  <div class="w-full h-full flex flex-col p-4 bg-n-background">
    <!-- Cabeçalho com botão de comparação -->
    <div class="flex justify-between items-center mb-4">
      <div class="flex items-center">
        <Avatar :username="'RAG Assistant'" :size="24" />
        <span class="ml-2 font-medium text-n-slate-12">RAG Assistant</span>
      </div>
      <div class="flex items-center gap-2">
        <button
          @click="toggleDocumentList"
          class="p-2 text-n-slate-11 hover:text-n-slate-12 hover:bg-n-weak rounded-md transition-colors"
          title="Ver documentos"
        >
          🔍
        </button>
        <button
          @click="toggleDocumentUpload"
          class="px-3 py-1 bg-n-brand text-n-white rounded-md text-sm hover:brightness-110 transition-all"
          title="Adicionar novo documento"
        >
          Novo Documento
        </button>
        <button 
          v-if="!showCompare" 
          class="px-3 py-1 bg-n-strong text-n-white rounded-md text-sm"
          @click="toggleCompare"
        >
          Compare RAG
        </button>
        <button 
          v-else 
          class="px-3 py-1 bg-n-ruby-8 text-n-white rounded-md text-sm"
          @click="toggleCompare"
          :title="`Comparando ${selectedDocumentsForComparison.length} documento(s)`"
        >
          Fechar Compare ({{ selectedDocumentsForComparison.length }})
        </button>
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
            <Avatar :username="'RAG'" :size="48" />
            <p class="mt-4 text-n-slate-11">Compare sua base de conhecimento</p>
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
          <div class="flex items-center justify-between mb-1">
            <label class="block text-sm font-medium text-n-slate-12">Prompt do Sistema:</label>
            <div class="flex items-center gap-2">
              <button
                @click="toggleCompareDocumentUpload"
                class="px-3 py-1 bg-n-brand text-n-white rounded-md text-sm hover:brightness-110 transition-all"
                title="Upload documento para comparação"
              >
                ☁️
              </button>
              <button
                @click="handleReplaceAllDocuments"
                class="px-3 py-1 bg-n-ruby-8 text-n-white rounded-md text-sm hover:brightness-110 transition-all"
                title="Substituir todos os documentos"
              >
                🔄 
              </button>
            </div>
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
            <Avatar :username="'RAG'" :size="48" />
            <p class="mt-4 text-n-slate-11">Compare sua base de conhecimento</p>
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
    
    <!-- Document List Modal -->
    <DocumentList 
      :isVisible="showDocumentList" 
      @close="closeDocumentList" 
    />
    
    <!-- Document Upload Modal -->
    <DocumentUpload 
      :isVisible="showDocumentUpload" 
      @close="closeDocumentUpload"
      @uploaded="handleDocumentUploaded"
    />
    
    <!-- Document Selector Modal -->
    <DocumentSelector 
      :isVisible="showDocumentSelector" 
      @close="closeDocumentSelector"
      @documentsSelected="handleDocumentsSelected"
    />
    
    <!-- Compare Document Upload Modal -->
    <CompareDocumentUpload 
      :isVisible="showCompareDocumentUpload" 
      @close="closeCompareDocumentUpload"
      @uploaded="handleCompareDocumentUploaded"
    />
  </div>
</template>