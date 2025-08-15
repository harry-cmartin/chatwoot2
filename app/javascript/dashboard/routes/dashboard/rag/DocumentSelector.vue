<script setup>
import { ref, onMounted, toRefs, watch } from 'vue';
import FluentIcon from 'shared/components/FluentIcon/Index.vue';
import axios from 'axios';

const props = defineProps({
  isVisible: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(['close', 'documentsSelected']);

// Estado do componente
const documents = ref([]);
const selectedDocuments = ref([]);
const isLoading = ref(false);
const isSubmitting = ref(false);
const selectAll = ref(false);
const error = ref('');

// Função para buscar documentos
const fetchDocuments = async () => {
  isLoading.value = true;
  error.value = '';
  
  try {
    const response = await axios.post('https://anzol.encha.top/webhook/d7263f61-3852-4824-9871-955f4fac03d8', {
      user: {
        id: "1"
      }
    });
    
    documents.value = response.data || [];
  } catch (err) {
    console.error('Erro ao buscar documentos:', err);
    error.value = 'Erro ao carregar documentos. Tente novamente.';
  } finally {
    isLoading.value = false;
  }
};

// Função para alternar seleção de um documento
const toggleDocument = (docId) => {
  const index = selectedDocuments.value.findIndex(doc => doc.id === docId);
  
  if (index > -1) {
    selectedDocuments.value.splice(index, 1);
  } else {
    selectedDocuments.value.push({ id: docId });
  }
  
  // Atualiza o estado do "selecionar todos"
  selectAll.value = selectedDocuments.value.length === documents.value.length;
};

// Função para selecionar/deselecionar todos
const toggleSelectAll = () => {
  if (selectAll.value) {
    selectedDocuments.value = documents.value.map(doc => ({ id: doc.id }));
  } else {
    selectedDocuments.value = [];
  }
};

// Função para verificar se um documento está selecionado
const isDocumentSelected = (docId) => {
  return selectedDocuments.value.some(doc => doc.id === docId);
};

// Função para enviar documentos selecionados
const submitSelectedDocuments = async () => {
  if (selectedDocuments.value.length === 0) {
    error.value = 'Selecione pelo menos um documento.';
    return;
  }
  
  isSubmitting.value = true;
  error.value = '';
  
  try {
    const response = await axios.post('https://anzol.encha.top/webhook/52148aae-27fa-44e8-a92c-cc4bc27ce9a8', {
      continueFiles: selectedDocuments.value
    });
    
    // Emite evento com os documentos selecionados
    emit('documentsSelected', selectedDocuments.value);
    
    // Fecha o modal
    closeModal();
  } catch (err) {
    console.error('Erro ao enviar documentos:', err);
    error.value = 'Erro ao processar documentos selecionados. Tente novamente.';
  } finally {
    isSubmitting.value = false;
  }
};

// Função para fechar o modal
const closeModal = () => {
  selectedDocuments.value = [];
  selectAll.value = false;
  error.value = '';
  emit('close');
};

// Busca documentos quando o modal é aberto
onMounted(() => {
  if (props.isVisible) {
    fetchDocuments();
  }
});

// Observa mudanças na visibilidade
const { isVisible } = toRefs(props);
watch(isVisible, (newValue) => {
  if (newValue) {
    fetchDocuments();
  }
});
</script>

<template>
  <div
    v-if="isVisible"
    class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50"
    @click.self="closeModal"
  >
    <div class="bg-white dark:bg-n-solid-2 rounded-lg shadow-xl w-full max-w-2xl max-h-[80vh] flex flex-col">
      <!-- Cabeçalho -->
      <div class="flex items-center justify-between p-6 border-b border-n-weak">
        <h2 class="text-lg font-semibold text-n-slate-12">Selecionar Documentos para Comparação</h2>
        <button
          @click="closeModal"
          class="p-1 text-n-slate-11 hover:text-n-slate-12 hover:bg-n-weak rounded-md transition-colors"
        >
          <FluentIcon icon="dismiss" :size="20" />
        </button>
      </div>

      <!-- Conteúdo -->
      <div class="flex-1 p-6 overflow-hidden">
        <!-- Estado de carregamento -->
        <div v-if="isLoading" class="flex items-center justify-center py-12">
          <div class="flex items-center gap-2 text-n-slate-11">
            <div class="w-4 h-4 border-2 border-n-brand border-t-transparent rounded-full animate-spin"></div>
            <span>Carregando documentos...</span>
          </div>
        </div>

        <!-- Erro -->
        <div v-else-if="error" class="text-center py-12">
          <div class="text-n-ruby-11 mb-4">{{ error }}</div>
          <button
            @click="fetchDocuments"
            class="px-4 py-2 bg-n-brand text-n-white rounded-md hover:brightness-110 transition-all"
          >
            Tentar Novamente
          </button>
        </div>

        <!-- Lista de documentos -->
        <div v-else-if="documents.length > 0" class="space-y-4">
          <!-- Checkbox para selecionar todos -->
          <div class="flex items-center gap-3 p-3 bg-n-weak rounded-lg">
            <input
              id="select-all"
              v-model="selectAll"
              type="checkbox"
              class="w-4 h-4 text-n-brand bg-n-background border-n-weak rounded focus:ring-n-brand focus:ring-2"
              @change="toggleSelectAll"
            />
            <label for="select-all" class="text-sm font-medium text-n-slate-12 cursor-pointer">
              Selecionar todos os documentos ({{ documents.length }})
            </label>
          </div>

          <!-- Lista de documentos -->
          <div class="max-h-64 overflow-y-auto space-y-2">
            <div
              v-for="document in documents"
              :key="document.id"
              class="flex items-center gap-3 p-3 border border-n-weak rounded-lg hover:bg-n-weak transition-colors cursor-pointer"
              @click="toggleDocument(document.id)"
            >
              <input
                :id="`doc-${document.id}`"
                :checked="isDocumentSelected(document.id)"
                type="checkbox"
                class="w-4 h-4 text-n-brand bg-n-background border-n-weak rounded focus:ring-n-brand focus:ring-2"
                @click.stop
                @change="toggleDocument(document.id)"
              />
              <div class="flex-1">
                <div class="text-sm font-medium text-n-slate-12">
                  {{ document.name || document.title || `Documento ${document.id}` }}
                </div>
                <div v-if="document.description" class="text-xs text-n-slate-11 mt-1">
                  {{ document.description }}
                </div>
              </div>
              <FluentIcon 
                icon="document" 
                :size="16" 
                class="text-n-slate-11" 
              />
            </div>
          </div>

          <!-- Documentos selecionados -->
          <div v-if="selectedDocuments.length > 0" class="mt-4">
            <h3 class="text-sm font-medium text-n-slate-12 mb-2">
              Documentos Selecionados ({{ selectedDocuments.length }})
            </h3>
            <div class="flex flex-wrap gap-2">
              <span
                v-for="selectedDoc in selectedDocuments"
                :key="selectedDoc.id"
                class="inline-flex items-center gap-1 px-2 py-1 bg-n-brand text-n-white text-xs rounded-md"
              >
                {{ documents.find(d => d.id === selectedDoc.id)?.name || documents.find(d => d.id === selectedDoc.id)?.title || `Doc ${selectedDoc.id}` }}
                <button
                  @click="toggleDocument(selectedDoc.id)"
                  class="hover:bg-white hover:bg-opacity-20 rounded-sm p-0.5"
                >
                  <FluentIcon icon="dismiss" :size="12" />
                </button>
              </span>
            </div>
          </div>
        </div>

        <!-- Estado vazio -->
        <div v-else class="text-center py-12">
          <FluentIcon icon="document" :size="48" class="text-n-slate-11 mx-auto mb-4" />
          <p class="text-n-slate-11">Nenhum documento encontrado</p>
        </div>
      </div>

      <!-- Rodapé -->
      <div class="flex items-center justify-between p-6 border-t border-n-weak">
        <button
          @click="closeModal"
          class="px-4 py-2 text-n-slate-11 hover:text-n-slate-12 hover:bg-n-weak rounded-md transition-colors"
        >
          Cancelar
        </button>
        <button
          @click="submitSelectedDocuments"
          :disabled="selectedDocuments.length === 0 || isSubmitting"
          class="px-4 py-2 bg-n-brand text-n-white rounded-md hover:brightness-110 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
        >
          <div v-if="isSubmitting" class="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
          {{ isSubmitting ? 'Enviando...' : 'Enviar Selecionados' }}
        </button>
      </div>
    </div>
  </div>
</template>