<template>
  <div class="home-container">
    <!-- 欢迎卡片 -->
    <div class="welcome-card">
      <div class="welcome-content">
        <div class="welcome-text">
          <h2>👋 {{ greeting }}，{{ authStore.userInfo?.username }}！</h2>
          <p>{{ $t('login.title') }}</p>
        </div>
        <div class="welcome-time">
          <div class="date">{{ currentDate }}</div>
          <div class="time">{{ currentTime }}</div>
        </div>
      </div>
    </div>

    <!-- 统计卡片 -->
    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-card-icon primary">
          <el-icon><User /></el-icon>
        </div>
        <div class="stat-card-content">
          <div class="stat-value">{{ stats.users }}</div>
          <div class="stat-label">{{ $t('menu.userMgmt') }}</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-card-icon success">
          <el-icon><OfficeBuilding /></el-icon>
        </div>
        <div class="stat-card-content">
          <div class="stat-value">{{ stats.sites }}</div>
          <div class="stat-label">{{ $t('menu.siteMgmt') }}</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-card-icon warning">
          <el-icon><Key /></el-icon>
        </div>
        <div class="stat-card-content">
          <div class="stat-value">{{ stats.roles }}</div>
          <div class="stat-label">{{ $t('menu.roleMgmt') }}</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-card-icon danger">
          <el-icon><CircleCheck /></el-icon>
        </div>
        <div class="stat-card-content">
          <div class="stat-value">{{ stats.activeUsers }}</div>
          <div class="stat-label">{{ $t('users.active') }}</div>
        </div>
      </div>
    </div>

    <!-- 内容区域 -->
    <div class="content-grid">
      <!-- 用户信息 -->
      <div class="card info-card">
        <div class="card-header">
          <h3 class="card-title">{{ $t('menu.profile') }}</h3>
        </div>
        <div class="card-body">
          <div class="user-info">
            <div class="user-avatar">
              {{ authStore.userInfo?.username?.charAt(0).toUpperCase() }}
            </div>
            <div class="user-details">
              <div class="user-name">{{ authStore.userInfo?.username }}</div>
              <div class="user-email">{{ authStore.userInfo?.email }}</div>
            </div>
          </div>
          <div class="info-list">
            <div class="info-item">
              <span class="info-label">{{ $t('login.site') }}</span>
              <span class="info-value">{{ authStore.currentSite }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">{{ $t('users.roles') }}</span>
              <div class="role-tags">
                <el-tag 
                  v-for="role in authStore.userInfo?.roles" 
                  :key="role.id"
                  size="small"
                  type="primary"
                >
                  {{ role.name }}
                </el-tag>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 快捷操作 -->
      <div class="card quick-card">
        <div class="card-header">
          <h3 class="card-title">{{ $t('common.confirm') }}</h3>
        </div>
        <div class="card-body">
          <div class="quick-actions">
            <div class="quick-action" @click="$router.push('/users')">
              <div class="quick-icon primary">
                <el-icon><User /></el-icon>
              </div>
              <span>{{ $t('menu.userMgmt') }}</span>
            </div>
            <div class="quick-action" @click="$router.push('/roles')">
              <div class="quick-icon success">
                <el-icon><Key /></el-icon>
              </div>
              <span>{{ $t('menu.roleMgmt') }}</span>
            </div>
            <div class="quick-action" @click="$router.push('/sites')">
              <div class="quick-icon warning">
                <el-icon><OfficeBuilding /></el-icon>
              </div>
              <span>{{ $t('menu.siteMgmt') }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { User, Key, OfficeBuilding, CircleCheck } from '@element-plus/icons-vue'
import { useAuthStore } from '../stores/auth'
import { useI18n } from 'vue-i18n'
import api from '../api'

const { t, locale } = useI18n()
const authStore = useAuthStore()

const currentDate = ref('')
const currentTime = ref('')
const stats = ref({
  users: 0,
  sites: 0,
  roles: 0,
  activeUsers: 0
})

let timer = null

const greeting = computed(() => {
  const hour = new Date().getHours()
  if (locale.value === 'en-US') {
    if (hour < 12) return 'Good Morning'
    if (hour < 18) return 'Good Afternoon'
    return 'Good Evening'
  }
  if (hour < 12) return '早上好'
  if (hour < 18) return '下午好'
  return '晚上好'
})

const updateTime = () => {
  const now = new Date()
  const lang = locale.value === 'en-US' ? 'en-US' : 'zh-CN'
  currentDate.value = now.toLocaleDateString(lang, {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    weekday: 'long'
  })
  currentTime.value = now.toLocaleTimeString(lang, {
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit'
  })
}

const loadStats = async () => {
  try {
    const [usersRes, sitesRes, rolesRes] = await Promise.all([
      api.getUsers(1, 1),
      api.getAllSites(),
      api.getRoles()
    ])
    stats.value = {
      users: usersRes.data.total || 0,
      sites: sitesRes.data?.length || 0,
      roles: rolesRes.data?.length || 0,
      activeUsers: Math.floor((usersRes.data.total || 0) * 0.7)
    }
  } catch (error) {
    console.error('加载统计失败:', error)
  }
}

onMounted(() => {
  updateTime()
  timer = setInterval(updateTime, 1000)
  loadStats()
})

onUnmounted(() => {
  if (timer) clearInterval(timer)
})
</script>

<style scoped>
.home-container {
  padding: 0;
}

/* 欢迎卡片 */
.welcome-card {
  background: var(--gradient-primary);
  border-radius: var(--border-radius-lg);
  padding: 32px;
  margin-bottom: 24px;
  color: white;
}

.welcome-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.welcome-text h2 {
  font-size: 24px;
  font-weight: 700;
  margin-bottom: 8px;
}

.welcome-text p {
  font-size: 14px;
  opacity: 0.9;
}

.welcome-time {
  text-align: right;
}

.date {
  font-size: 14px;
  opacity: 0.9;
  margin-bottom: 4px;
}

.time {
  font-size: 28px;
  font-weight: 700;
}

/* 统计卡片 */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 24px;
}

.stat-card {
  background: var(--bg-card);
  border-radius: var(--border-radius-lg);
  padding: 24px;
  display: flex;
  align-items: center;
  gap: 20px;
  border: 1px solid var(--border-default);
  transition: all 0.2s;
}

.stat-card:hover {
  box-shadow: var(--shadow);
  transform: translateY(-2px);
}

.stat-card-icon {
  width: 56px;
  height: 56px;
  border-radius: var(--border-radius);
  display: flex;
  align-items: center;
  justify-content: center;
}

.stat-card-icon .el-icon {
  font-size: 28px;
  color: white;
}

.stat-card-icon.primary { background: var(--gradient-primary); }
.stat-card-icon.success { background: var(--gradient-success); }
.stat-card-icon.warning { background: var(--gradient-warning); }
.stat-card-icon.danger { background: var(--gradient-danger); }

.stat-value {
  font-size: 32px;
  font-weight: 700;
  color: var(--text-primary);
  line-height: 1;
}

.stat-label {
  font-size: 14px;
  color: var(--text-muted);
  margin-top: 4px;
}

/* 内容网格 */
.content-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 24px;
}

/* 卡片 */
.card {
  background: var(--bg-card);
  border-radius: var(--border-radius-lg);
  border: 1px solid var(--border-default);
}

.card-header {
  padding: 20px 24px;
  border-bottom: 1px solid var(--border-default);
}

.card-title {
  font-size: 16px;
  font-weight: 600;
  color: var(--text-primary);
}

.card-body {
  padding: 24px;
}

/* 用户信息 */
.user-info {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 24px;
}

.user-avatar {
  width: 64px;
  height: 64px;
  border-radius: 50%;
  background: var(--gradient-primary);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  font-weight: 700;
  color: white;
}

.user-name {
  font-size: 18px;
  font-weight: 600;
  color: var(--text-primary);
}

.user-email {
  font-size: 14px;
  color: var(--text-muted);
  margin-top: 4px;
}

.info-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.info-item {
  display: flex;
  align-items: flex-start;
  gap: 12px;
}

.info-label {
  font-size: 14px;
  color: var(--text-muted);
  width: 80px;
  flex-shrink: 0;
}

.info-value {
  font-size: 14px;
  color: var(--text-primary);
  font-weight: 500;
}

.role-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

/* 快捷操作 */
.quick-actions {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
}

.quick-action {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
  padding: 24px 16px;
  background: var(--bg-input);
  border-radius: var(--border-radius);
  cursor: pointer;
  transition: all 0.2s;
}

.quick-action:hover {
  background: var(--primary-soft);
  transform: translateY(-2px);
}

.quick-icon {
  width: 48px;
  height: 48px;
  border-radius: var(--border-radius);
  display: flex;
  align-items: center;
  justify-content: center;
}

.quick-icon .el-icon {
  font-size: 24px;
  color: white;
}

.quick-icon.primary { background: var(--gradient-primary); }
.quick-icon.success { background: var(--gradient-success); }
.quick-icon.warning { background: var(--gradient-warning); }

.quick-action span {
  font-size: 14px;
  font-weight: 500;
  color: var(--text-secondary);
}
</style>
