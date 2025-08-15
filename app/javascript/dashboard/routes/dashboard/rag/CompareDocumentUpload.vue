<script setup>
import { ref } from 'vue';
import { generateRandomString } from 'widget/helpers/utils';
import axios from 'axios';

const props = defineProps({
  isVisible: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(['close', 'uploaded']);

// Estado do componente
const selectedFile = ref(null);
const selectedImage = ref(null);
const isUploading = ref(false);
const uploadProgress = ref(0);
const error = ref('');
const success = ref(false);
const isDragOver = ref(false);
const isImageDragOver = ref(false);

// Função para selecionar arquivo
const selectFile = (event) => {
  const file = event.target.files[0];
  if (file) {
    selectedFile.value = file;
    error.value = '';
    success.value = false;
  }
};

// Função para selecionar imagem
const selectImage = (event) => {
  const file = event.target.files[0];
  if (file) {
    selectedImage.value = file;
    error.value = '';
    success.value = false;
  }
};

// Função para drag and drop - Documento
const handleDragOver = (event) => {
  event.preventDefault();
  isDragOver.value = true;
};

const handleDragLeave = (event) => {
  event.preventDefault();
  isDragOver.value = false;
};

const handleDrop = (event) => {
  event.preventDefault();
  isDragOver.value = false;
  
  const files = event.dataTransfer.files;
  if (files.length > 0) {
    selectedFile.value = files[0];
    error.value = '';
    success.value = false;
  }
};

// Função para drag and drop - Imagem
const handleImageDragOver = (event) => {
  event.preventDefault();
  isImageDragOver.value = true;
};

const handleImageDragLeave = (event) => {
  event.preventDefault();
  isImageDragOver.value = false;
};

const handleImageDrop = (event) => {
  event.preventDefault();
  isImageDragOver.value = false;
  
  const files = event.dataTransfer.files;
  if (files.length > 0) {
    selectedImage.value = files[0];
    error.value = '';
    success.value = false;
  }
};

// Função para fazer upload
const uploadFile = async () => {
  if (!selectedFile.value) {
    error.value = 'Por favor, selecione um arquivo.';
    return;
  }
  
  isUploading.value = true;
  error.value = '';
  uploadProgress.value = 0;
  
  try {
    const formData = new FormData();
    formData.append('userid', '1');
    formData.append('fileid', generateRandomString());
    formData.append('File', selectedFile.value);
    
    const response = await axios.post(
      'https://anzol.encha.top/webhook/5bce5cc2-9d69-4df9-a48f-a87ade751bcc',
      formData,
      {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
        onUploadProgress: (progressEvent) => {
          uploadProgress.value = Math.round(
            (progressEvent.loaded * 100) / progressEvent.total
          );
        },
      }
    );
    
    success.value = true;
    emit('uploaded');
    
    // Fecha o modal após 2 segundos
    setTimeout(() => {
      closeModal();
    }, 2000);
    
  } catch (err) {
    console.error('Erro no upload:', err);
    error.value = 'Erro ao fazer upload do arquivo. Tente novamente.';
  } finally {
    isUploading.value = false;
  }
};

// Função para fechar modal
const closeModal = () => {
  selectedFile.value = null;
  selectedImage.value = null;
  isUploading.value = false;
  uploadProgress.value = 0;
  error.value = '';
  success.value = false;
  isDragOver.value = false;
  isImageDragOver.value = false;
  emit('close');
};

// Função para remover arquivo selecionado
const removeFile = () => {
  selectedFile.value = null;
  error.value = '';
  success.value = false;
};

// Função para remover imagem selecionada
const removeImage = () => {
  selectedImage.value = null;
  error.value = '';
  success.value = false;
};

// Função para formatar tamanho do arquivo
const formatFileSize = (bytes) => {
  if (bytes === 0) return '0 Bytes';
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

const getFileIcon = (filename) => {
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
    <div v-if="isVisible" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50" @click.self="closeModal">
      <div class="bg-white dark:bg-n-solid-1 rounded-lg shadow-lg w-full max-w-4xl max-h-[80vh] overflow-hidden">
        <!-- Header -->
        <div class="flex items-center justify-between px-6 py-4 border-b border-n-alpha-3">
          <h3 class="text-lg font-semibold text-n-slate-12">Upload para Comparação</h3>
          <button
            class="w-8 h-8 flex items-center justify-center rounded-lg text-n-slate-11 hover:bg-n-alpha-2 focus:bg-n-alpha-2 transition-colors"
            @click="closeModal"
            title="Fechar"
          >
            ✕
          </button>
        </div>
        
        <!-- Content -->
        <div class="p-6">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Document Upload Section -->
            <div>
              <h4 class="text-sm font-medium text-n-slate-12 mb-3">📄 Documento</h4>
              <div 
                class="border-2 border-dashed rounded-lg p-6 text-center transition-colors"
                :class="{
                  'border-n-brand bg-n-brand/5': isDragOver,
                  'border-n-alpha-3 hover:border-n-alpha-4': !isDragOver && !selectedFile,
                  'border-n-green-9 bg-n-green-9/5': selectedFile
                }"
                @drop="handleDrop"
                @dragover="handleDragOver"
                @dragleave="handleDragLeave"
              >
                <div v-if="!selectedFile">
                  <div class="w-10 h-10 bg-n-alpha-2 rounded-full flex items-center justify-center mx-auto mb-3 text-xl">
                    ☁️
                  </div>
                  <p class="text-xs text-n-slate-12 mb-2">Arraste um arquivo aqui ou</p>
                  <label class="inline-flex items-center gap-2 px-3 py-2 bg-n-brand text-white rounded-lg hover:brightness-110 focus:brightness-110 transition-all text-xs font-medium cursor-pointer">
                    📎 Selecionar
                    <input 
                      type="file" 
                      class="hidden" 
                      @change="selectFile"
                      accept=".pdf,.doc,.docx,.txt,.md"
                    >
                  </label>
                  <p class="text-xs text-n-slate-11 mt-2">PDF, DOC, DOCX, TXT, MD</p>
                </div>
                
                <!-- Selected File -->
                <div v-else class="flex items-center gap-3 p-3 bg-white dark:bg-n-solid-2 rounded-lg">
                  <div class="w-8 h-8 bg-n-alpha-2 rounded-lg flex items-center justify-center text-lg flex-shrink-0">
                    {{ getFileIcon(selectedFile.name) }}
                  </div>
                  
                  <div class="flex-1 min-w-0 text-left">
                    <h4 class="text-xs font-medium text-n-slate-12 truncate" :title="selectedFile.name">
                      {{ selectedFile.name }}
                    </h4>
                    <p class="text-xs text-n-slate-11">
                      {{ formatFileSize(selectedFile.size) }}
                    </p>
                  </div>
                  
                  <button
                    class="w-6 h-6 flex items-center justify-center text-n-slate-11 hover:text-n-ruby-11 hover:bg-n-alpha-2 rounded-lg transition-colors flex-shrink-0"
                    @click="removeFile"
                    title="Remover arquivo"
                  >
                    ✕
                  </button>
                </div>
              </div>
            </div>

            <!-- Image Upload Section -->
            <div>
              <h4 class="text-sm font-medium text-n-slate-12 mb-3">🖼️ Imagem</h4>
              <div 
                class="border-2 border-dashed rounded-lg p-6 text-center transition-colors"
                :class="{
                  'border-n-brand bg-n-brand/5': isImageDragOver,
                  'border-n-alpha-3 hover:border-n-alpha-4': !isImageDragOver && !selectedImage,
                  'border-n-green-9 bg-n-green-9/5': selectedImage
                }"
                @drop="handleImageDrop"
                @dragover="handleImageDragOver"
                @dragleave="handleImageDragLeave"
              >
                <div v-if="!selectedImage">
                  <div class="w-10 h-10 bg-n-alpha-2 rounded-full flex items-center justify-center mx-auto mb-3 text-xl">
                    🖼️
                  </div>
                  <p class="text-xs text-n-slate-12 mb-2">Arraste uma imagem aqui ou</p>
                  <label class="inline-flex items-center gap-2 px-3 py-2 bg-n-brand text-white rounded-lg hover:brightness-110 focus:brightness-110 transition-all text-xs font-medium cursor-pointer">
                    📎 Selecionar
                    <input 
                      type="file" 
                      class="hidden" 
                      @change="selectImage"
                      accept=".jpg,.jpeg,.png,.gif,.webp,.bmp"
                    >
                  </label>
                  <p class="text-xs text-n-slate-11 mt-2">JPG, PNG, GIF, WEBP, BMP</p>
                </div>
                
                <!-- Selected Image -->
                <div v-else class="space-y-3">
                  <!-- Image Preview -->
                  <div class="w-full h-24 bg-n-alpha-2 rounded-lg flex items-center justify-center overflow-hidden">
                    <img 
                      :src="selectedImage ? URL.createObjectURL(selectedImage) : ''"
                      :alt="selectedImage?.name"
                      class="max-w-full max-h-full object-contain"
                    >
                  </div>
                  
                  <!-- Image Info -->
                  <div class="flex items-center gap-3 p-3 bg-white dark:bg-n-solid-2 rounded-lg">
                    <div class="w-8 h-8 bg-n-alpha-2 rounded-lg flex items-center justify-center text-lg flex-shrink-0">
                      🖼️
                    </div>
                    
                    <div class="flex-1 min-w-0 text-left">
                      <h4 class="text-xs font-medium text-n-slate-12 truncate" :title="selectedImage.name">
                        {{ selectedImage.name }}
                      </h4>
                      <p class="text-xs text-n-slate-11">
                        {{ formatFileSize(selectedImage.size) }}
                      </p>
                    </div>
                    
                    <button
                      class="w-6 h-6 flex items-center justify-center text-n-slate-11 hover:text-n-ruby-11 hover:bg-n-alpha-2 rounded-lg transition-colors flex-shrink-0"
                      @click="removeImage"
                      title="Remover imagem"
                    >
                      ✕
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Progress Bar -->
          <div v-if="isUploading" class="mt-4 space-y-2">
            <div class="flex justify-between text-sm">
              <span class="text-n-slate-11">Enviando...</span>
              <span class="text-n-slate-11">{{ uploadProgress }}%</span>
            </div>
            <div class="w-full bg-n-alpha-3 rounded-full h-2">
              <div
                class="bg-n-brand h-2 rounded-full transition-all duration-300"
                :style="{ width: uploadProgress + '%' }"
              ></div>
            </div>
          </div>

          <!-- Success Message -->
          <div v-if="success" class="mt-4 flex items-center gap-2 text-n-emerald-11">
            <span class="text-lg">✅</span>
            <span class="text-sm">Arquivo enviado com sucesso!</span>
          </div>

          <!-- Error Message -->
          <div v-if="error" class="mt-4 p-3 bg-n-ruby-2 border border-n-ruby-6 rounded-lg">
            <div class="flex items-center gap-2 text-n-ruby-11">
              <span class="text-lg">❌</span>
              <span class="text-sm">{{ error }}</span>
            </div>
          </div>
        </div>

        <!-- Footer -->
        <div class="flex items-center justify-between p-6 border-t border-n-alpha-3">
          <button
            @click="closeModal"
            class="px-4 py-2 text-n-slate-11 hover:text-n-slate-12 hover:bg-n-alpha-2 rounded-lg transition-colors"
          >
            Cancelar
          </button>
          <button
            @click="uploadFile"
            :disabled="!selectedFile || isUploading || success"
            class="px-4 py-2 bg-n-brand text-white rounded-lg hover:brightness-110 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
          >
            <div v-if="isUploading" class="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
            <span v-else-if="success" class="text-lg">✅</span>
            <span v-else class="text-lg">☁️</span>
            {{ isUploading ? 'Enviando...' : success ? 'Enviado!' : 'Enviar' }}
          </button>
        </div>
      </div>
    </div>
  </transition>
</template>

<style scoped>
/* Todos os estilos foram convertidos para classes Tailwind */
</style>