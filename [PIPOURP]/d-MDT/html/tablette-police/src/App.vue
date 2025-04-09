<template>
  <div class="flex min-h-screen bg-gradient-to-r from-teal-700 to-blue-600 font-sans">

    <!-- Menu latéral -->
    <aside class="w-64 bg-teal-800 text-white p-6">
      <h1 class="text-2xl font-bold text-center mb-8">📱 Tablette Police</h1>

      <nav class="flex flex-col space-y-4">
        <button 
          v-for="tab in tabs"
          :key="tab"
          :class="[ 
            'py-3 px-4 rounded-lg transition transform hover:scale-105',
            activeTab === tab ? 'bg-teal-500 shadow-lg' : 'bg-teal-600 hover:bg-teal-500'
          ]"
          @click="activeTab = tab">
          {{ tab }}
        </button>
      </nav>
    </aside>

    <!-- Contenu principal -->
    <main class="flex-1 p-10 overflow-y-auto">
      <div class="bg-white rounded-xl shadow-xl p-8 max-w-6xl mx-auto">
        <component :is="currentComponent" />
      </div>
    </main>

  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import Casier from './components/Casier.vue'
import Vehicules from './components/Vehicules.vue'
import Rapports from './components/Rapports.vue'

const tabs = ['Casier', 'Véhicules', 'Rapports']
const activeTab = ref('Casier')

const currentComponent = computed(() => {
  switch (activeTab.value) {
    case 'Casier': return Casier
    case 'Véhicules': return Vehicules
    case 'Rapports': return Rapports
    default: return Casier
  }
})
</script>

<style scoped>
html, body, #app {
  height: 100%;
  margin: 0;
  padding: 0;
}

body {
  display: flex;
  min-height: 100vh;
  background-color: #242424;
  color: rgba(255, 255, 255, 0.87);
}

#app {
  width: 100%;
}

button {
  cursor: pointer;
}

main {
  display: flex;
  flex-direction: column;
}

aside {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}
</style>
