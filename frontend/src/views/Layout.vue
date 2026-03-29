<template>
  <!-- 使用 :key="locale" 强制在语言切换时重新渲染整个布局，确保所有翻译即时生效 -->
  <el-container :key="locale" class="layout-container">
    <!-- 侧边栏 -->
    <el-aside :width="isCollapse ? '72px' : '260px'" class="aside">
      <div class="sidebar-header">
        <div class="sidebar-logo">
          <div class="sidebar-logo-icon">A</div>
          <transition name="fade">
            <span v-if="!isCollapse" class="sidebar-logo-text">AdminSystem</span>
          </transition>
        </div>
      </div>

      <el-menu
        :default-active="activeMenu"
        :collapse="isCollapse"
        :unique-opened="true"
        class="side-menu"
        background-color="#1A2332"
        text-color="#A0AEC0"
        active-text-color="#FFFFFF"
        @select="handleMenuSelect"
      >
        <template v-for="menu in menus" :key="menu.id">
          <!-- 有子菜单 -->
          <el-sub-menu v-if="menu.children && menu.children.length" :index="menu.path">
            <template #title>
              <el-icon><component :is="getIcon(menu.icon)" /></el-icon>
              <span>{{ $t(menu.name) }}</span>
            </template>
            <el-menu-item v-for="child in menu.children" :key="child.id" :index="child.path">
              <el-icon><component :is="getIcon(child.icon)" /></el-icon>
              <template #title>{{ $t(child.name) }}</template>
            </el-menu-item>
          </el-sub-menu>
          <!-- 无子菜单 -->
          <el-menu-item v-else :index="menu.path">
            <el-icon><component :is="getIcon(menu.icon)" /></el-icon>
            <template #title>{{ $t(menu.name) }}</template>
          </el-menu-item>
        </template>
      </el-menu>
    </el-aside>

    <!-- 主内容区 -->
    <el-container class="main-container">
      <!-- 头部 -->
      <el-header class="header">
        <div class="header-left">
          <div class="header-collapse-btn" @click="isCollapse = !isCollapse">
            <el-icon :size="18">
              <Fold v-if="!isCollapse" />
              <Expand v-else />
            </el-icon>
          </div>
          <el-breadcrumb separator="/">
            <el-breadcrumb-item :to="{ path: '/home' }">
              <el-icon><HomeFilled /></el-icon>
              {{ $t('menu.home') }}
            </el-breadcrumb-item>
            <el-breadcrumb-item v-if="route.meta?.title">
              {{ $t(route.meta.title) }}
            </el-breadcrumb-item>
          </el-breadcrumb>
        </div>

        <div class="header-right">
          <!-- 语言切换 -->
          <el-dropdown @command="handleLanguageChange" trigger="click">
            <div class="header-action">
              <el-icon><Bell /></el-icon>
              <span>{{ locale === 'zh-CN' ? '中文' : 'English' }}</span>
            </div>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="zh-CN" :disabled="locale === 'zh-CN'">简体中文</el-dropdown-item>
                <el-dropdown-item command="en-US" :disabled="locale === 'en-US'">English</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>

          <el-dropdown @command="handleCommand" trigger="click">
            <div class="header-profile">
              <div class="header-profile-avatar">
                {{ authStore.userInfo?.username?.charAt(0).toUpperCase() }}
              </div>
              <div class="header-profile-info">
                <span class="header-profile-name">{{ authStore.userInfo?.username }}</span>
                <span class="header-profile-role">{{ authStore.userInfo?.roles?.[0]?.name }}</span>
              </div>
              <el-icon class="arrow"><ArrowDown /></el-icon>
            </div>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="profile">
                  <el-icon><User /></el-icon>
                  {{ $t('menu.profile') }}
                </el-dropdown-item>
                <el-dropdown-item command="settings">
                  <el-icon><Setting /></el-icon>
                  {{ $t('menu.systemSettings') }}
                </el-dropdown-item>
                <el-dropdown-item divided command="logout">
                  <el-icon><SwitchButton /></el-icon>
                  {{ $t('common.logout') }}
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>

      <!-- 标签页 -->
      <div class="tabs-container">
        <el-tabs
          v-model="tabStore.currentTab"
          type="card"
          class="main-tabs"
          @tab-click="handleTabClick"
          @tab-remove="handleTabRemove"
        >
          <el-tab-pane
            v-for="tab in tabStore.tabs"
            :key="tab.path + locale"
            :label="$t(tab.meta?.title || tab.title)"
            :name="tab.path"
            :closable="tab.closable"
          />
        </el-tabs>
      </div>

      <!-- 页面内容 -->
      <el-main class="main-content">
        <router-view v-slot="{ Component }">
          <transition name="fade" mode="out-in">
            <!-- 绑定 :key 确保子页面在切换语言时也重绘文字 -->
            <component :is="Component" :key="route.fullPath + locale" />
          </transition>
        </router-view>
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { 
  HomeFilled, Fold, Expand, Setting, User, SwitchButton, ArrowDown, Bell, Monitor, Key, OfficeBuilding
} from '@element-plus/icons-vue'
import { useAuthStore } from '../stores/auth'
import { useTabStore } from '../stores/tabs'
import { useI18n } from 'vue-i18n'
import api from '../api'

const { t, locale } = useI18n()
const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()
const tabStore = useTabStore()

const menus = ref([])
const isCollapse = ref(false)
const activeMenu = computed(() => route.path)

const iconMap = { HomeFilled, User, Key, Setting, OfficeBuilding, Monitor }
const getIcon = (name) => iconMap[name] || HomeFilled

const loadMenus = async () => {
  try {
    const res = await api.getMenus()
    // 现在后端返回的 menu.name 是国际化 Key (如 'menu.userMgmt')
    menus.value = res.data
  } catch (error) {
    console.error('Failed to load menus:', error)
  }
}

const handleMenuSelect = (index) => router.push(index)
const handleTabClick = (tab) => router.push(tab.props.name)
const handleTabRemove = (path) => {
  tabStore.removeTab(path)
  if (tabStore.currentTab === path) {
    const last = tabStore.tabs[tabStore.tabs.length - 1]
    router.push(last.path)
  }
}

const handleLanguageChange = (lang) => {
  locale.value = lang
  localStorage.setItem('locale', lang)
  ElMessage.success(lang === 'en-US' ? 'Switched to English' : '已切换为中文')
}

const handleCommand = (command) => {
  if (command === 'logout') {
    ElMessageBox.confirm(t('common.logout') + '?', t('common.confirm'), {
      confirmButtonText: t('common.confirm'),
      cancelButtonText: t('common.cancel'),
      type: 'warning'
    }).then(() => {
      authStore.logout()
      router.push('/login')
    }).catch(() => {})
  }
}

onMounted(async () => {
  if (!authStore.token) { router.push('/login'); return }
  if (!authStore.userInfo) {
    try {
      const res = await api.getCurrentUser()
      authStore.setUserInfo(res.data)
    } catch (e) {}
  }
  if (!authStore.sites?.length) {
    try {
      const res = await api.getSites()
      authStore.setSites(res.data)
    } catch (e) {}
  }
  await loadMenus()
  tabStore.addTab({ path: '/home', name: 'Home', meta: { title: 'menu.home' } })
})

watch(() => route.path, (path) => {
  if (route.meta?.title) {
    tabStore.addTab({ path, name: route.name, meta: { title: route.meta.title } })
  }
})
</script>

<style>
/* ========== Design System Variables ========== */
:root {
  --primary: #5B8DEF;
  --primary-light: #8FADFF;
  --primary-dark: #3D6DD4;
  --primary-soft: rgba(91, 141, 239, 0.1);
  --gradient-primary: linear-gradient(135deg, #5B8DEF 0%, #7EC5FF 100%);
  --gradient-success: linear-gradient(135deg, #48BB78 0%, #68D391 100%);
  --gradient-danger: linear-gradient(135deg, #E53E3E 0%, #FC8181 100%);
  --bg-body: #EEF2F8;
  --bg-card: #FFFFFF;
  --bg-sidebar: #1A2332;
  --bg-sidebar-hover: #2D3748;
  --bg-sidebar-active: rgba(91, 141, 239, 0.15);
  --bg-input: #F8FAFC;
  --bg-header: #FFFFFF;
  --border-default: #E2E8F0;
  --border-radius-sm: 6px;
  --border-radius: 10px;
  --border-radius-lg: 16px;
  --text-primary: #1A2332;
  --text-secondary: #4A5568;
  --text-muted: #8896A8;
  --success: #48BB78;
  --danger: #E53E3E;
  --shadow-sm: 0 1px 3px rgba(26, 36, 50, 0.06);
  --shadow: 0 4px 12px rgba(26, 36, 50, 0.08);
  --shadow-lg: 0 8px 24px rgba(26, 36, 50, 0.12);
  --sidebar-width: 260px;
  --sidebar-collapsed: 72px;
  --header-height: 64px;
}

/* ========== Base Styles ========== */
* { margin: 0; padding: 0; box-sizing: border-box; }
body { font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif; background: var(--bg-body); }
a { text-decoration: none; color: inherit; }
button { font-family: inherit; cursor: pointer; border: none; background: none; }
</style>

<style scoped>
.layout-container {
  height: 100vh;
  display: flex;
}

/* ========== Sidebar ========== */
.aside {
  background: var(--bg-sidebar);
  transition: width 0.3s ease;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.sidebar-header {
  height: var(--header-height);
  display: flex;
  align-items: center;
  padding: 0 20px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
  flex-shrink: 0;
}

.sidebar-logo {
  display: flex;
  align-items: center;
  gap: 12px;
}

.sidebar-logo-icon {
  width: 36px;
  height: 36px;
  background: var(--gradient-primary);
  border-radius: var(--border-radius);
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 14px;
  color: white;
  flex-shrink: 0;
}

.sidebar-logo-text {
  font-size: 18px;
  font-weight: 700;
  color: white;
  white-space: nowrap;
}

/* ========== Menu ========== */
.side-menu {
  border-right: none;
  background: transparent !important;
  flex: 1;
  overflow-y: auto;
}

.side-menu:not(.el-menu--collapse) {
  width: 260px;
}

.side-menu :deep(.el-menu-item),
.side-menu :deep(.el-sub-menu__title) {
  height: 44px;
  line-height: 44px;
  margin: 4px 8px;
  border-radius: var(--border-radius);
  transition: all 0.2s ease;
}

.side-menu :deep(.el-menu-item:hover),
.side-menu :deep(.el-sub-menu__title:hover) {
  background: var(--bg-sidebar-hover) !important;
  color: white !important;
}

.side-menu :deep(.el-menu-item.is-active) {
  background: var(--bg-sidebar-active) !important;
  color: var(--primary-light) !important;
}

.side-menu :deep(.el-sub-menu .el-menu-item) {
  height: 40px;
  line-height: 40px;
  margin: 2px 8px;
}

/* ========== Main Container ========== */
.main-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* ========== Header ========== */
.header {
  height: var(--header-height);
  background: var(--bg-header);
  border-bottom: 1px solid var(--border-default);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 16px;
}

.header-collapse-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  border-radius: var(--border-radius-sm);
  color: var(--text-secondary);
  cursor: pointer;
  transition: all 0.2s;
}

.header-collapse-btn:hover {
  background: var(--bg-input);
  color: var(--primary);
}

.header-right {
  display: flex;
  align-items: center;
  gap: 16px;
}

.header-action {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 12px;
  border-radius: var(--border-radius);
  cursor: pointer;
  font-size: 14px;
  color: var(--text-secondary);
  transition: all 0.2s;
}

.header-action:hover {
  background: var(--bg-input);
  color: var(--primary);
}

.header-profile {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 6px 12px 6px 6px;
  border-radius: var(--border-radius);
  cursor: pointer;
  transition: background 0.2s;
}

.header-profile:hover {
  background: var(--bg-input);
}

.header-profile-avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: var(--gradient-primary);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: 600;
  font-size: 14px;
}

.header-profile-info {
  display: flex;
  flex-direction: column;
}

.header-profile-name {
  font-size: 14px;
  font-weight: 600;
  color: var(--text-primary);
}

.header-profile-role {
  font-size: 12px;
  color: var(--text-muted);
}

.arrow {
  font-size: 12px;
  color: var(--text-muted);
}

/* ========== Tabs ========== */
.tabs-container {
  display: flex;
  align-items: center;
  background: var(--bg-card);
  padding: 0 16px;
  border-bottom: 1px solid var(--border-default);
}

.main-tabs {
  flex: 1;
}

.main-tabs :deep(.el-tabs__header) {
  margin: 0;
  border: none;
}

.main-tabs :deep(.el-tabs__nav) {
  border: none;
}

.main-tabs :deep(.el-tabs__item) {
  border: none;
  border-radius: var(--border-radius-sm);
  margin: 8px 4px 0 0;
  padding: 0 16px;
  height: 32px;
  line-height: 32px;
  font-size: 13px;
  font-weight: 500;
  color: var(--text-secondary);
  background: var(--bg-input);
  transition: all 0.2s;
}

.main-tabs :deep(.el-tabs__item:hover) {
  color: var(--primary);
  background: var(--primary-soft);
}

.main-tabs :deep(.el-tabs__item.is-active) {
  color: white;
  background: var(--primary);
}

.main-tabs :deep(.el-tabs__nav-wrap::after) {
  display: none;
}

/* ========== Main Content ========== */
.main-content {
  padding: 20px;
  overflow-y: auto;
  flex: 1;
}

/* ========== Transitions ========== */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
