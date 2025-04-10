<template>
    <div id= "rapport-wrapper"class="space-y-8">
      <div>
        <label for="search" class="block text-xl font-semibold text-teal-200">🔍 Recherche par nom ou ID</label>
        <input v-model="search" 
               id="search" 
               type="text"
               class="w-full px-6 py-3 mt-2 rounded-xl bg-gray-800 text-white shadow-lg focus:outline-none focus:ring-2 focus:ring-teal-400 transition duration-300 ease-in-out transform hover:scale-105"
               placeholder="Entrez le nom ou l'ID du suspect..." 
               @keyup.enter="fetchCriminalRecord" />
      </div>
  
      <div v-if="criminalRecord" class="bg-white text-black p-6 rounded-xl shadow-2xl mt-6">
        <h3 class="text-2xl font-bold text-teal-600 mb-4">Casier de : {{ criminalRecord.name }}</h3>
  
        <p><strong>ID:</strong> {{ criminalRecord.id }}</p>
        <p><strong>Crimes:</strong></p>
        <ul class="list-disc pl-5">
          <li v-for="(crime, index) in criminalRecord.crimes" :key="index">{{ crime }}</li>
        </ul>
  
        <p class="mt-4"><strong>Date de dernière condamnation:</strong> {{ criminalRecord.lastConviction }}</p>
      </div>
  
      <div v-else-if="search && !loading && !criminalRecord" class="text-center text-red-500">
        Aucune donnée trouvée pour "{{ search }}".
      </div>
  
      <div v-if="loading" class="text-center text-teal-500">🔄 Recherche en cours...</div>
    </div>
  </template>
  
  <script setup>
  import { ref } from 'vue'
  
  const search = ref('')
  const loading = ref(false)
  const criminalRecord = ref(null)
  
  const fetchCriminalRecord = async () => {
    if (!search.value) return
  
    loading.value = true
    criminalRecord.value = null
  
    setTimeout(() => {
      if (search.value.toLowerCase() === "john doe") {
        criminalRecord.value = {
          id: "12345",
          name: "John Doe",
          crimes: ["Vol de voiture", "Escroquerie"],
          lastConviction: "2025-03-15"
        }
      } else {
        criminalRecord.value = null
      }
      loading.value = false
    }, 1500)
  }
  </script>
  
  <style scoped>
  .rapport-wrapper {
  width: 100%;
  padding: 30px;
  }
  /* Aucun style spécifique ici, tout est géré par Tailwind CSS */
  </style>
  