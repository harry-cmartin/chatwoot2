<script setup>
import { ref, computed } from 'vue';
import axios from 'axios';
import { generateRandomString } from 'widget/helpers/utils';

const props = defineProps({
  isVisible: {
    type: Boolean,
    default: false
  }
});

const emit = defineEmits(['close', 'uploaded']);

const selectedFile = ref(null);
const selectedImage = ref(null);
const uploading = ref(false);
const error = ref(null);
const dragOver = ref(false);
const imageDragOver = ref(false);

const imagePreviewUrl = computed(() => {
  if (!selectedImage.value) return '';
  try {
    if (typeof window !== 'undefined' && window.URL && window.URL.createObjectURL) {
      return window.URL.createObjectURL(selectedImage.value);
    }
    return '';
  } catch (e) {
    console.warn('Error creating object URL:', e);
    return '';
  }
});

const handleFileSelect = (event) => {
  const file = event.target.files[0];
  if (file) {
    selectedFile.value = file;
    error.value = null;
  }
};

const handleImageSelect = (event) => {
  const file = event.target.files[0];
  if (file) {
    selectedImage.value = file;
    error.value = null;
  }
};

const handleDrop = (event) => {
  event.preventDefault();
  dragOver.value = false;
  
  const files = event.dataTransfer.files;
  if (files.length > 0) {
    selectedFile.value = files[0];
    error.value = null;
  }
};

const handleDragOver = (event) => {
  event.preventDefault();
  dragOver.value = true;
};

const handleDragLeave = () => {
  dragOver.value = false;
};

const handleImageDrop = (event) => {
  event.preventDefault();
  imageDragOver.value = false;
  
  const files = event.dataTransfer.files;
  if (files.length > 0) {
    selectedImage.value = files[0];
    error.value = null;
  }
};

const handleImageDragOver = (event) => {
  event.preventDefault();
  imageDragOver.value = true;
};

const handleImageDragLeave = () => {
  imageDragOver.value = false;
};

const removeFile = () => {
  selectedFile.value = null;
  error.value = null;
};

const removeImage = () => {
  selectedImage.value = null;
  error.value = null;
};

const handleUpload = async () => {
  if (!selectedFile.value) {
    error.value = 'Por favor, selecione um arquivo';
    return;
  }

  if (!selectedImage.value) {
    error.value = 'Por favor, selecione uma imagem';
    return;
  }

  try {
    uploading.value = true;
    error.value = null;

    const formData = new FormData();
    formData.append('archive', selectedFile.value);
    formData.append('photo', selectedImage.value);
    formData.append('user_id', '12312415');

    const response = await axios.post(
      'https://anzol.encha.com.br/webhook/14119839-b401-4fc8-af67-36f1250fc028',
      formData,
      {
        headers: {
          'Content-Type': 'multipart/form-data'
        }
      }
    );

    // Emitir evento de sucesso
    emit('uploaded');
    handleClose();
  } catch (err) {
    error.value = err.response?.data?.message || err.message || 'Erro ao fazer upload do arquivo';
    console.error('Erro no upload:', err);
  } finally {
    uploading.value = false;
  }
};

const handleClose = () => {
  selectedFile.value = null;
  selectedImage.value = null;
  error.value = null;
  uploading.value = false;
  emit('close');
};

const formatFileSize = (bytes) => {
  if (!bytes) return '';
  
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(1024));
  
  return Math.round(bytes / Math.pow(1024, i) * 100) / 100 + ' ' + sizes[i];
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
    <div v-if="isVisible" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white dark:bg-n-solid-1 rounded-lg shadow-lg w-full max-w-4xl max-h-[80vh] overflow-hidden">
        <!-- Header -->
        <div class="flex items-center justify-between px-6 py-4 border-b border-n-alpha-3">
          <h3 class="text-lg font-semibold text-n-slate-12">Novo Documento</h3>
          <button
            class="w-8 h-8 flex items-center justify-center rounded-lg text-n-slate-11 hover:bg-n-alpha-2 focus:bg-n-alpha-2 transition-colors"
            @click="handleClose"
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
                  'border-n-brand bg-n-brand/5': dragOver,
                  'border-n-alpha-3 hover:border-n-alpha-4': !dragOver && !selectedFile,
                  'border-n-green-9 bg-n-green-9/5': selectedFile
                }"
                @drop="handleDrop"
                @dragover="handleDragOver"
                @dragleave="handleDragLeave"
              >
                <div v-if="!selectedFile">
                  <div class="w-10 h-10 bg-n-alpha-2 rounded-full flex items-center justify-center mx-auto mb-3 text-xl">
                    📁
                  </div>
                  <p class="text-xs text-n-slate-12 mb-2">Arraste um arquivo aqui ou</p>
                  <label class="inline-flex items-center gap-2 px-3 py-2 bg-n-brand text-white rounded-lg hover:brightness-110 focus:brightness-110 transition-all text-xs font-medium cursor-pointer">
                    📎 Selecionar
                    <input 
                      type="file" 
                      class="hidden" 
                      @change="handleFileSelect"
                      accept=".pdf,.doc,.docx,.txt,.xls,.xlsx,.ppt,.pptx"
                    >
                  </label>
                  <p class="text-xs text-n-slate-11 mt-2">PDF, DOC, TXT, XLS, PPT</p>
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
                    class="w-6 h-6 flex items-center justify-center bg-n-ruby-9 text-white rounded-lg hover:bg-n-ruby-10 focus:bg-n-ruby-10 transition-colors flex-shrink-0"
                    @click="removeFile"
                    title="Remover arquivo"
                  >
                    🗑️
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
                  'border-n-brand bg-n-brand/5': imageDragOver,
                  'border-n-alpha-3 hover:border-n-alpha-4': !imageDragOver && !selectedImage,
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
                      @change="handleImageSelect"
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
                      :src="imagePreviewUrl"
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
                      class="w-6 h-6 flex items-center justify-center bg-n-ruby-9 text-white rounded-lg hover:bg-n-ruby-10 focus:bg-n-ruby-10 transition-colors flex-shrink-0"
                      @click="removeImage"
                      title="Remover imagem"
                    >
                      🗑️
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
          
          <!-- Error Message -->
          <div v-if="error" class="mt-4 p-3 bg-n-ruby-9/10 border border-n-ruby-9/20 rounded-lg">
            <p class="text-sm text-n-ruby-11">{{ error }}</p>
          </div>
          
          <!-- Actions -->
          <div class="flex items-center justify-end gap-3 mt-6">
            <button
              class="px-4 py-2 text-n-slate-11 hover:text-n-slate-12 hover:bg-n-alpha-2 rounded-lg transition-colors text-sm font-medium"
              @click="handleClose"
              :disabled="uploading"
            >
              Cancelar
            </button>
            <button
              class="inline-flex items-center gap-2 px-4 py-2 bg-n-green-9 text-white rounded-lg hover:bg-n-green-10 focus:bg-n-green-10 transition-colors text-sm font-medium disabled:opacity-50 disabled:cursor-not-allowed"
              @click="handleUpload"
              :disabled="!selectedFile || !selectedImage || uploading"
            >
              <div v-if="uploading" class="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
              <span>{{ uploading ? 'Enviando...' : 'Enviar' }}</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  </transition>
</template>

<style scoped>
/* Todos os estilos foram convertidos para classes Tailwind */
</style>