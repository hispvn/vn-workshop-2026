<script setup>
import { useNav } from '@slidev/client'
const { currentPage, total } = useNav()
</script>

<template>
  <div class="absolute bottom-2 right-4 text-xs opacity-30 font-mono">
    {{ currentPage }} / {{ total }}
  </div>
</template>
