<template>
  <div class="rapport-wrapper w-full max-w-7xl mx-auto px-4 py-8">
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">

      <!-- Formulaire -->
      <div class="glass-card">
        <h3 class="text-3xl font-bold text-white mb-6">📝 Nouveau Rapport</h3>

        <form @submit.prevent="createReport">
          <div class="mb-5">
            <label class="block text-sm font-medium text-white mb-2">Titre du rapport</label>
            <input
              v-model="newReport.title"
              type="text"
              class="w-full"
              placeholder="Ex. Vol de véhicule"
              required
            />
          </div>

          <div class="mb-5">
            <label class="block text-sm font-medium text-white mb-2">Description détaillée</label>
            <textarea
              v-model="newReport.description"
              rows="4"
              class="w-full"
              placeholder="Détaillez clairement l'intervention"
              required
            ></textarea>
          </div>

          <button
            type="submit"
            class="w-full"
          >
            ➕ Soumettre
          </button>
        </form>
      </div>

      <!-- Liste des rapports -->
      <div class="glass-card">
        <h3 class="text-3xl font-bold text-teal-200 mb-6">📂 Rapports Récents</h3>

        <ul>
          <li
            v-for="report in reports"
            :key="report.id"
            class="mb-4 p-4 bg-opacity-20 bg-gray-800 rounded-lg transition duration-300 ease-in-out hover:bg-opacity-30"
          >
            <h4 class="text-xl font-semibold text-teal-300 mb-2">📌 {{ report.title }}</h4>
            <p class="text-sm text-gray-200"><span class="font-semibold">Description :</span> {{ report.description }}</p>
            <p class="text-xs text-gray-400"><span class="font-semibold">Date :</span> {{ report.date }}</p>
          </li>
        </ul>
      </div>

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

  reports.value.unshift({
    id: reports.value.length + 1,
    title: newReport.value.title,
    description: newReport.value.description,
    date: new Date().toLocaleDateString()
  })

  newReport.value.title = ''
  newReport.value.description = ''
}
</script>

<style scoped>
.rapport-wrapper {
  width: 100%;
  padding: 30px;
}

.glass-card {
  background: rgba(255, 255, 255, 0.05);
  backdrop-filter: blur(12px);
  border-radius: 1rem;
  padding: 2rem;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.2);
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.glass-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 32px rgba(0, 0, 0, 0.3);
}

input, textarea, button {
  border-radius: 8px;
  padding: 0.75rem 1rem;
  transition: all 0.2s ease;
  background: rgba(0, 0, 0, 0.4);
  color: #fff;
  border: 1px solid rgba(255, 255, 255, 0.2);
  margin-top: 0.5rem;
}

button {
  background: linear-gradient(90deg, #4f46e5, #6366f1);
  color: white;
  cursor: pointer;
}

button:hover {
  opacity: 0.9;
}

ul {
  list-style: none;
  padding: 0;
}
</style>
