<script setup>
import { ref, watch } from 'vue';
import axios from 'axios';

const props = defineProps({
  isVisible: {
    type: Boolean,
    default: false
  }
});

const emit = defineEmits(['close']);

const documents = ref([]);
const loading = ref(false);
const error = ref(null);

// Observa mudanças na visibilidade para buscar documentos
watch(() => props.isVisible, (newValue) => {
  if (newValue) {
    fetchDocuments();
  }
});

const fetchDocuments = async () => {
  try {
    loading.value = true;
    error.value = null;
    
    const response = await axios.post('https://anzol.encha.top/webhook/d7263f61-3852-4824-9871-955f4fac03d8', {
      user: {
        id: "1"
      }
    });
    
    documents.value = Array.isArray(response.data) ? response.data : [];
  } catch (err) {
    error.value = err.message;
    console.error('Erro ao buscar documentos:', err);
  } finally {
    loading.value = false;
  }
};

const handleRefresh = () => {
  fetchDocuments();
};

const handleClose = () => {
  emit('close');
};

const getDocumentIcon = (filename) => {
  if (!filename) return '📄';
  
  const ext = filename.toLowerCase().split('.').pop();
  
  switch (ext) {
    case 'pdf':
      return '📕';
    case 'doc':
    case 'docx':
      return '📘';
    case 'xls':
    case 'xlsx':
      return '📊';
    case 'ppt':
    case 'pptx':
      return '📋';
    case 'txt':
      return '📝';
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'gif':
      return '🖼️';
    default:
      return '📄';
  }
};

const formatFileSize = (bytes) => {
  if (!bytes) return '';
  
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(1024));
  
  return Math.round(bytes / Math.pow(1024, i) * 100) / 100 + ' ' + sizes[i];
};

const handleDeleteDocument = async (documentId) => {
  if (!documentId) return;
  
  if (!confirm('Tem certeza que deseja excluir este documento?')) {
    return;
  }

  try {
    const response = await axios.post('https://anzol.encha.top/webhook/cebbada7-d827-4d15-93da-96b0aa492e37', {
      File: {
        id: documentId.toString()
      }
    });

    // Atualizar lista após exclusão
    fetchDocuments();
  } catch (err) {
    console.error('Erro ao excluir documento:', err);
    alert(`Erro ao excluir documento: ${err.message}`);
  }
};

const formatDate = (dateString) => {
  if (!dateString) return '';
  
  // Se a data já está no formato DD-MM-YYYY, apenas retorna
  if (dateString.includes('-') && dateString.split('-').length === 3) {
    return dateString;
  }
  
  // Caso contrário, tenta converter
  try {
    return new Date(dateString).toLocaleDateString('pt-BR');
  } catch {
    return dateString;
  }
};
</script>

<template>
  <transition 
    enter-active-class="transition-opacity duration-300 ease-out"
    enter-from-class="opacity-0"
    enter-to-class="opacity-100"
    leave-active-class="transition-opacity duration-300 ease-in"
    leave-from-class="opacity-100"
    leave-to-class="opacity-0"
  >
    <div v-if="isVisible" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white dark:bg-n-solid-1 rounded-lg shadow-lg w-full max-w-2xl max-h-[80vh] overflow-hidden">
        <!-- Header -->
        <div class="flex items-center justify-between px-6 py-4 border-b border-n-alpha-3">
          <h3 class="text-lg font-semibold text-n-slate-12">Documentos na Base</h3>
          <div class="flex items-center gap-2">
            <button
              class="w-8 h-8 flex items-center justify-center rounded-lg text-n-slate-11 hover:bg-n-alpha-2 focus:bg-n-alpha-2 transition-colors disabled:opacity-50"
              :disabled="loading"
              @click="handleRefresh"
              title="Atualizar"
            >
              🔄
            </button>
            <button
              class="w-8 h-8 flex items-center justify-center rounded-lg text-n-slate-11 hover:bg-n-alpha-2 focus:bg-n-alpha-2 transition-colors"
              @click="handleClose"
              title="Fechar"
            >
              ✕
            </button>
          </div>
        </div>
        
        <!-- Content -->
        <div class="p-6 max-h-[60vh] overflow-y-auto">
          <!-- Loading State -->
          <div v-if="loading" class="flex flex-col items-center justify-center py-8 text-center">
            <div class="w-8 h-8 border-2 border-n-alpha-3 border-t-n-brand rounded-full animate-spin mb-4"></div>
            <p class="text-sm text-n-slate-11">Carregando documentos...</p>
          </div>
          
          <!-- Error State -->
          <div v-else-if="error" class="flex flex-col items-center justify-center py-8 text-center">
            <div class="w-12 h-12 bg-n-ruby-9/10 rounded-full flex items-center justify-center mb-4 text-2xl">
              ⚠️
            </div>
            <p class="text-sm text-n-slate-11 mb-4">Erro ao carregar: {{ error }}</p>
            <button 
              class="inline-flex items-center gap-2 px-4 py-2 bg-n-brand text-white rounded-lg hover:brightness-110 focus:brightness-110 transition-all text-sm font-medium"
              @click="handleRefresh"
            >
              🔄 Tentar novamente
            </button>
          </div>
          
          <!-- Empty State -->
          <div v-else-if="documents.length === 0" class="flex flex-col items-center justify-center py-8 text-center">
            <div class="w-12 h-12 bg-n-alpha-2 rounded-full flex items-center justify-center mb-4 text-2xl">
              📄
            </div>
            <p class="text-sm text-n-slate-11">Nenhum documento encontrado</p>
          </div>
          
          <!-- Documents List -->
          <div v-else class="space-y-3">
            <div 
              v-for="(doc, index) in documents" 
              :key="doc.id || index"
              class="flex items-center gap-3 p-3 border border-n-alpha-3 rounded-lg hover:bg-n-alpha-2 transition-colors"
            >
              <!-- Document Icon -->
              <div class="w-10 h-10 bg-n-alpha-2 rounded-lg flex items-center justify-center text-xl flex-shrink-0">
                {{ getDocumentIcon(doc.title) }}
              </div>
              
              <!-- Document Info -->
              <div class="flex-1 min-w-0">
                <h4 class="text-sm font-medium text-n-slate-12 truncate" :title="doc.title || `Documento ${index + 1}`">
                  {{ doc.title || `Documento ${index + 1}` }}
                </h4>
                <div v-if="doc.created_at" class="flex items-center gap-1 text-xs text-n-slate-11 mt-1">
                  {{ formatDate(doc.created_at) }}
                </div>
              </div>
              
              <!-- Delete Button -->
              <button
                class="w-8 h-8 flex items-center justify-center bg-n-ruby-9 text-white rounded-lg hover:bg-n-ruby-10 focus:bg-n-ruby-10 transition-colors flex-shrink-0"
                @click="handleDeleteDocument(doc.id)"
                title="Excluir documento"
              >
                🗑️
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </transition>
</template>

<style scoped>
/* Todos os estilos foram convertidos para classes Tailwind */
</style>