<template>
    <div class="space-y-6">
      <h2 class="text-xl font-semibold">🚗 Gestion des Véhicules</h2>
      <p>C'est ici que tu peux gérer les véhicules.</p>
  
      <div>
        <label for="vehicle-search" class="block text-lg">🔍 Rechercher un véhicule</label>
        <input id="vehicle-search" class="w-full px-4 py-2 mt-2 rounded-lg bg-gray-800 text-white" placeholder="Rechercher un véhicule..." />
      </div>
  
      <div class="mt-4">
        <h3 class="text-lg font-semibold">Véhicules Récents :</h3>
        <ul class="list-disc pl-5">
          <li>Véhicule 1</li>
          <li>Véhicule 2</li>
          <li>Véhicule 3</li>
        </ul>
      </div>
    </div>
  </template>
  
  <script setup>
  // Ce composant peut inclure des fonctionnalités comme la recherche de véhicules,
  // ou d'autres informations concernant les véhicules de la police.
  </script>
  
  <style scoped>
  /* Styling pour rendre ça joli avec Tailwind */
  </style>
  