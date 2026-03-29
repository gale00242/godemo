<template>
  <el-container class="layout-container">
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
          <el-sub-menu v-if="menu.children && menu.children.length" :index="menu.path + ''">
            <template #title>
              <el-icon><component :is="getIcon(menu.icon)" /></el-icon>
              <span>{{ getMenuTitle(menu.name) }}</span>
            </template>
            <el-menu-item v-for="child in menu.children" :key="child.id" :index="child.path">
              <el-icon><component :is="getIcon(child.icon)" /></el-icon>
              <template #title>{{ getMenuTitle(child.name) }}</template>
            </el-menu-item>
          </el-sub-menu>
          <!-- 无子菜单 -->
          <el-menu-item v-else :index="menu.path">
            <el-icon><component :is="getIcon(menu.icon)" /></el-icon>
            <template #title>{{ getMenuTitle(menu.name) }}</template>
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
            <el-breadcrumb-item v-if="currentRouteName">
              {{ getMenuTitle(currentRouteName) }}
            </el-breadcrumb-item>
          </breadcrumb>
        </div>

        <div class="header-right">
          <!-- 语言切换 -->
          <el-dropdown @command="handleLanguageChange" trigger="click">
            <div class="header-action">
              <el-icon><Bell /></el-icon>
              <span>{{ currentLocaleDisplay }}</span>
            </div>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="zh-CN" :class="{ active: currentLocale === 'zh-CN' }">
                  简体中文
                </el-dropdown-item>
                <el-dropdown-item command="en-US" :class="{ active: currentLocale === 'en-US' }">
                  English
                </el-dropdown-item>
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
            :key="tab.path"
            :label="getMenuTitle(tab.title)"
            :name="tab.path"
            :closable="tab.closable"
          />
        </el-tabs>
        <div class="tabs-actions">
          <el-dropdown @command="handleTabsCommand" trigger="click">
            <span class="tabs-action-btn">
              <el-icon><MoreFilled /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="refresh">
                  <el-icon><Refresh /></el-icon>
                  {{ $t('common.reset') }}
                </el-dropdown-item>
                <el-dropdown-item command="closeCurrent">
                  <el-icon><Close /></el-icon>
                  {{ $t('common.delete') }}
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </div>

      <!-- 页面内容 -->
      <el-main class="main-content">
        <router-view v-slot="{ Component }">
          <transition name="fade" mode="out-in">
            <component :is="Component" />
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
  HomeFilled, Fold, Expand, MoreFilled, Refresh, Close, 
  FolderDelete, Remove, Setting, User, SwitchButton, ArrowDown,
  Monitor, Key, OfficeBuilding, Bell
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

const currentLocale = computed(() => locale.value)
const currentLocaleDisplay = computed(() => locale.value === 'zh-CN' ? '中文' : 'English')

const activeMenu = computed(() => route.path)

const currentRouteName = computed(() => {
  const menu = menus.value.find(m => m.path === route.path)
  if (menu) return menu.name
  for (const m of menus.value) {
    if (m.children) {
      const child = m.children.find(c => c.path === route.path)
      if (child) return child.name
    }
  }
  return route.meta?.title || ''
})

const iconMap = {
  HomeFilled, User, Key, Setting, OfficeBuilding, Monitor
}

// 菜单映射表：必须严格对应数据库 init.sql 中的名称
const menuKeyMap = {
  '首页': 'home',
  '系统设置': 'systemSettings',
  '用户管理': 'userMgmt',
  '角色管理': 'roleMgmt',
  '站点管理': 'siteMgmt'
}

// 翻译函数：增加响应式 key 以强制重新渲染
const getMenuTitle = (name) => {
  if (!name) return ''
  const cleanName = name.trim()
  const key = menuKeyMap[cleanName]
  // 必须使用 t 函数，i18n 会自动追踪 locale 变化
  return key ? t('menu.' + key) : cleanName
}

const getIcon = (iconName) => iconMap[iconName] || HomeFilled

const loadMenus = async () => {
  try {
    const res = await api.getMenus()
    menus.value = res.data
  } catch (error) {
    console.error('加载菜单失败:', error)
  }
}

const handleMenuSelect = (index) => {
  let selectedMenu = null
  for (const menu of menus.value) {
    if (menu.path === index) {
      selectedMenu = menu
      break
    }
    if (menu.children) {
      const child = menu.children.find(c => c.path === index)
      if (child) {
        selectedMenu = child
        break
      }
    }
  }
  if (selectedMenu) {
    tabStore.addTab({
      path: index,
      name: selectedMenu.name,
      meta: { title: selectedMenu.name }
    })
  }
  router.push(index)
}

const handleTabClick = (tab) => {
  const path = tab.props.name
  tabStore.setCurrentTab(path)
  router.push(path)
}

const handleTabRemove = (path) => {
  tabStore.removeTab(path)
  if (tabStore.currentTab === path) {
    router.push(tabStore.currentTab)
  }
}

const handleTabsCommand = (command) => {
  switch (command) {
    case 'refresh':
      window.location.reload()
      break
    case 'closeCurrent':
      handleTabRemove(tabStore.currentTab)
      break
  }
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
      ElMessage.success(t('common.success'))
    }).catch(() => {})
  }
}

const handleLanguageChange = (lang) => {
  locale.value = lang
  localStorage.setItem('locale', lang)
  ElMessage.success(lang === 'en-US' ? 'Language switched to English' : '语言已切换为中文')
}

watch(() => route.path, (path) => {
  const menu = menus.value.find(m => m.path === path)
  if (menu) {
    tabStore.addTab({ path, name: menu.name, meta: { title: menu.name } })
  } else {
    for (const m of menus.value) {
      if (m.children) {
        const child = m.children.find(c => c.path === path)
        if (child) {
          tabStore.addTab({ path, name: child.name, meta: { title: child.name } })
          break
        }
      }
    }
  }
}, { immediate: false })

onMounted(async () => {
  if (!authStore.token) {
    router.push('/login')
    return
  }
  
  if (!authStore.userInfo) {
    try {
      const res = await api.getCurrentUser()
      authStore.setUserInfo(res.data)
    } catch (error) {
      console.error('获取用户信息失败:', error)
    }
  }
  
  if (!authStore.sites?.length) {
    try {
      const res = await api.getSites()
      authStore.setSites(res.data)
    } catch (error) {
      console.error('获取站点失败:', error)
    }
  }
  
  await loadMenus()
  
  // 添加首页tab
  tabStore.addTab({ path: '/home', name: '首页', meta: { title: '首页' } })
})
</script>

<style>
/* 变量和基础样式保持不变 */
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
  --sidebar-width: 260px;
  --header-height: 64px;
}
* { margin: 0; padding: 0; box-sizing: border-box; }
body { font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif; background: var(--bg-body); }
</style>

<style scoped>
/* 样式部分保持不变 */
.layout-container { height: 100vh; display: flex; }
.aside { background: var(--bg-sidebar); transition: width 0.3s ease; overflow: hidden; display: flex; flex-direction: column; }
.sidebar-header { height: var(--header-height); display: flex; align-items: center; padding: 0 20px; border-bottom: 1px solid rgba(255, 255, 255, 0.08); flex-shrink: 0; }
.sidebar-logo { display: flex; align-items: center; gap: 12px; }
.sidebar-logo-icon { width: 36px; height: 36px; background: var(--gradient-primary); border-radius: var(--border-radius); display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 14px; color: white; flex-shrink: 0; }
.sidebar-logo-text { font-size: 18px; font-weight: 700; color: white; white-space: nowrap; }
.main-container { flex: 1; display: flex; flex-direction: column; overflow: hidden; }
.header { height: var(--header-height); background: var(--bg-header); border-bottom: 1px solid var(--border-default); display: flex; align-items: center; justify-content: space-between; padding: 0 24px; }
.header-left { display: flex; align-items: center; gap: 16px; }
.header-collapse-btn { display: flex; align-items: center; justify-content: center; width: 36px; height: 36px; border-radius: var(--border-radius-sm); color: var(--text-secondary); cursor: pointer; }
.header-right { display: flex; align-items: center; gap: 8px; }
.header-action { display: flex; align-items: center; gap: 6px; padding: 8px 12px; border-radius: var(--border-radius); cursor: pointer; font-size: 14px; color: var(--text-secondary); }
.header-profile { display: flex; align-items: center; gap: 12px; padding: 6px 12px 6px 6px; border-radius: var(--border-radius); cursor: pointer; }
.header-profile-avatar { width: 36px; height: 36px; border-radius: 50%; background: var(--gradient-primary); display: flex; align-items: center; justify-content: center; color: white; font-weight: 600; }
.tabs-container { display: flex; align-items: center; background: var(--bg-card); padding: 0 16px; border-bottom: 1px solid var(--border-default); }
.main-tabs { flex: 1; }
.main-tabs :deep(.el-tabs__header) { margin: 0; border: none; }
.main-content { padding: 16px; overflow-y: auto; flex: 1; }
.fade-enter-active, .fade-leave-active { transition: opacity 0.2s ease; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
</style>
