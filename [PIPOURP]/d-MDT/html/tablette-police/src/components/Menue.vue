<template>
    <div id="Menu" class="w-64 bg-gray-800 text-white min-h-screen p-4">
      <h2 class="text-2xl font-bold mb-6">Tablette Police</h2>
      <ul>
        <li class="mb-4">
          <router-link to="/" class="hover:text-gray-400">Dashboard</router-link>
        </li>
        <li class="mb-4">
          <router-link to="/vehicules" class="hover:text-gray-400">Véhicules</router-link>
        </li>
        <li class="mb-4">
          <router-link to="/rapports" class="hover:text-gray-400">Rapports</router-link>
        </li>
        <li class="mb-4">
          <router-link to="/casier" class="hover:text-gray-400">Casier Judiciaire</router-link>
        </li>
      </ul>
    </div>
  </template>
  
  <script setup>
  import { defineComponent } from 'vue';
  </script>
  
  <style scoped>


  /* Vous pouvez ajouter des styles personnalisés ici si nécessaire */
  </style>
  