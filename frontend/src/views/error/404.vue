<template>
  <div class="error-page">
    <el-result
      icon="warning"
      :title="$t('error.404.title')"
      :sub-title="$t('error.404.desc')"
    >
      <template #extra>
        <el-button type="primary" @click="goHome">{{ $t('error.backHome') }}</el-button>
      </template>
    </el-result>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'

const router = useRouter()
const goHome = () => {
  router.push('/')
}
</script>

<style scoped>
.error-page {
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: var(--bg-card);
  border-radius: var(--border-radius-lg);
}
</style>
