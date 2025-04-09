<template>
  <div class="space-y-8 max-w-4xl mx-auto"> <!-- Correction ici -->
  
    <!-- Formulaire pour créer un rapport -->
    <div class="bg-gradient-to-br from-teal-600 to-teal-500 p-8 rounded-xl shadow-xl">
      <h3 class="text-2xl font-bold text-white mb-4">📝 Créer un Nouveau Rapport</h3>

      <form @submit.prevent="createReport">
        <div class="mb-6">
          <label for="report-title" class="block text-sm font-semibold text-teal-100 mb-1">Titre du Rapport</label>
          <input v-model="newReport.title"
                 id="report-title"
                 type="text"
                 class="w-full px-4 py-2 rounded-lg bg-gray-800 text-white shadow-md border border-transparent focus:border-teal-400 transition duration-300"
                 placeholder="Ex. Vol de voiture"
                 required />
        </div>

        <div class="mb-6">
          <label for="report-description" class="block text-sm font-semibold text-teal-100 mb-1">Description détaillée</label>
          <textarea v-model="newReport.description"
                    id="report-description"
                    rows="4"
                    class="w-full px-4 py-2 rounded-lg bg-gray-800 text-white shadow-md border border-transparent focus:border-teal-400 transition duration-300"
                    placeholder="Décrivez précisément l'intervention"
                    required></textarea>
        </div>

        <button type="submit"
                class="w-full py-3 rounded-lg bg-gray-900 text-teal-200 font-semibold hover:bg-gray-800 transition duration-300">
          ➕ Soumettre le Rapport
        </button>
      </form>
    </div>

    <!-- Liste des rapports existants -->
    <div class="mt-8">
      <h3 class="text-2xl font-bold text-teal-200 mb-4">📂 Rapports Récents</h3>

      <ul class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <li v-for="report in reports" :key="report.id"
            class="bg-gray-800 text-white p-6 rounded-xl shadow-lg transform hover:-translate-y-1 hover:shadow-2xl transition duration-300 ease-in-out">
          <h4 class="text-lg font-semibold text-teal-300 mb-2">📌 {{ report.title }}</h4>
          <p class="text-sm mb-3"><span class="font-semibold">Description :</span> {{ report.description }}</p>
          <p class="text-xs text-gray-400"><span class="font-semibold">Date :</span> {{ report.date }}</p>
        </li>
      </ul>
    </div>
    
  </div>
</template>

<script setup>
import { ref } from 'vue'

const reports = ref([
  { id: 1, title: 'Intervention à la banque', description: 'Vol à main armée', date: '2025-04-01' },
  { id: 2, title: 'Contrôle de vitesse', description: 'Excès de vitesse', date: '2025-04-02' }
])

const newReport = ref({ title: '', description: '' })

const createReport = () => {
  if (!newReport.value.title || !newReport.value.description) return

  const newId = reports.value.length + 1
  const newDate = new Date().toLocaleDateString()

  reports.value.unshift({ id: newId, title: newReport.value.title, description: newReport.value.description, date: newDate })

  newReport.value.title = ''
  newReport.value.description = ''
}
</script>

<style scoped>
/* Entièrement stylisé avec Tailwind CSS */
</style>
