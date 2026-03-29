<template>
  <!-- 强制通过 :key="locale" 在语言改变时刷新整个组件，确保所有 getMenuTitle 重新执行 -->
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
              <span>{{ getMenuTitle(menu) }}</span>
            </template>
            <el-menu-item v-for="child in menu.children" :key="child.id" :index="child.path">
              <el-icon><component :is="getIcon(child.icon)" /></el-icon>
              <template #title>{{ getMenuTitle(child) }}</template>
            </el-menu-item>
          </el-sub-menu>
          <!-- 无子菜单 -->
          <el-menu-item v-else :index="menu.path">
            <el-icon><component :is="getIcon(menu.icon)" /></el-icon>
            <template #title>{{ getMenuTitle(menu) }}</template>
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
              {{ t('menu.home') }}
            </el-breadcrumb-item>
            <el-breadcrumb-item v-if="route.meta?.title">
              {{ t(route.meta.title) }}
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
                  {{ t('menu.profile') }}
                </el-dropdown-item>
                <el-dropdown-item command="settings">
                  <el-icon><Setting /></el-icon>
                  {{ t('menu.systemSettings') }}
                </el-dropdown-item>
                <el-dropdown-item divided command="logout">
                  <el-icon><SwitchButton /></el-icon>
                  {{ t('common.logout') }}
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
            :label="getTabLabel(tab)"
            :name="tab.path"
            :closable="tab.closable"
          />
        </el-tabs>
      </div>

      <!-- 页面内容 -->
      <el-main class="main-content">
        <router-view v-slot="{ Component }">
          <transition name="fade" mode="out-in">
            <!-- 给 component 绑定 key 强制刷新内页文字 -->
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
import { ElMessage } from 'element-plus'
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

// 建立一个名字到 Key 的映射作为最后的保底方案
const nameKeyMap = {
  '首页': 'home',
  'Home': 'home',
  '系统设置': 'systemSettings',
  'System Settings': 'systemSettings',
  '用户管理': 'userMgmt',
  'User Management': 'userMgmt',
  '角色管理': 'roleMgmt',
  'Role Management': 'roleMgmt',
  '站点管理': 'siteMgmt',
  'Site Management': 'siteMgmt'
}

/**
 * 核心翻译函数
 * 逻辑：路径匹配 > 名字映射 > 原始名称
 */
const getMenuTitle = (item) => {
  // 1. 尝试通过路由路径匹配
  const resolved = router.resolve(item.path)
  if (resolved && resolved.meta && resolved.meta.title) {
    return t(resolved.meta.title)
  }
  
  // 2. 尝试通过名字映射（处理数据库返回的中文名）
  const key = nameKeyMap[item.name.trim()]
  if (key) {
    return t('menu.' + key)
  }
  
  // 3. 兜底返回原名
  return item.name
}

const getTabLabel = (tab) => {
  const resolved = router.resolve(tab.path)
  if (resolved && resolved.meta && resolved.meta.title) {
    return t(resolved.meta.title)
  }
  return tab.title
}

const loadMenus = async () => {
  try {
    const res = await api.getMenus()
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
    authStore.logout()
    router.push('/login')
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
:root {
  --primary: #5B8DEF;
  --bg-body: #EEF2F8;
  --bg-card: #FFFFFF;
  --bg-sidebar: #1A2332;
  --bg-header: #FFFFFF;
  --border-default: #E2E8F0;
  --border-radius: 10px;
  --text-primary: #1A2332;
  --sidebar-width: 260px;
  --header-height: 64px;
}
* { margin: 0; padding: 0; box-sizing: border-box; }
body { font-family: 'Inter', sans-serif; background: var(--bg-body); }
</style>

<style scoped>
.layout-container { height: 100vh; display: flex; }
.aside { background: var(--bg-sidebar); transition: width 0.3s ease; display: flex; flex-direction: column; }
.sidebar-header { height: var(--header-height); display: flex; align-items: center; padding: 0 20px; border-bottom: 1px solid rgba(255, 255, 255, 0.08); }
.sidebar-logo { display: flex; align-items: center; gap: 12px; color: white; font-weight: 700; }
.sidebar-logo-icon { width: 36px; height: 36px; background: var(--primary); border-radius: var(--border-radius); display: flex; align-items: center; justify-content: center; }
.main-container { flex: 1; display: flex; flex-direction: column; overflow: hidden; }
.header { height: var(--header-height); background: var(--bg-header); border-bottom: 1px solid var(--border-default); display: flex; align-items: center; justify-content: space-between; padding: 0 24px; }
.header-left { display: flex; align-items: center; gap: 16px; }
.header-collapse-btn { cursor: pointer; color: #4A5568; }
.header-right { display: flex; align-items: center; gap: 16px; }
.header-action { cursor: pointer; color: #4A5568; font-size: 14px; display: flex; align-items: center; gap: 4px; }
.header-profile { display: flex; align-items: center; gap: 8px; cursor: pointer; }
.header-profile-avatar { width: 32px; height: 32px; border-radius: 50%; background: var(--primary); color: white; display: flex; align-items: center; justify-content: center; }
.tabs-container { background: white; padding: 0 16px; border-bottom: 1px solid var(--border-default); }
.main-tabs :deep(.el-tabs__header) { margin: 0; border-bottom: none; }
.main-content { padding: 20px; overflow-y: auto; flex: 1; }
.fade-enter-active, .fade-leave-active { transition: opacity 0.2s; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
</style>
