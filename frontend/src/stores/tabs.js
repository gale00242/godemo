import { defineStore } from 'pinia'

export const useTabStore = defineStore('tab', {
  state: () => ({
    tabs: [
      { path: '/home', name: 'Home', title: '首页', closable: false }
    ],
    currentTab: '/home'
  }),

  actions: {
    addTab(route) {
      // 不重复添加
      if (this.tabs.find(t => t.path === route.path)) {
        this.currentTab = route.path
        return
      }
      
      // 首页不可关闭
      const closable = route.path !== '/home'
      this.tabs.push({
        path: route.path,
        name: route.name,
        title: route.meta?.title || route.name,
        closable
      })
      this.currentTab = route.path
    },

    removeTab(path) {
      const index = this.tabs.findIndex(t => t.path === path)
      if (index === -1) return
      
      // 不能关闭首页
      if (path === '/home') return
      
      this.tabs.splice(index, 1)
      
      // 如果关闭的是当前tab，切换到上一个
      if (this.currentTab === path) {
        const newIndex = Math.max(0, index - 1)
        this.currentTab = this.tabs[newIndex].path
      }
    },

    setCurrentTab(path) {
      if (this.tabs.find(t => t.path === path)) {
        this.currentTab = path
      }
    },

    closeAllTabs() {
      this.tabs = [{ path: '/home', name: 'Home', title: '首页', closable: false }]
      this.currentTab = '/home'
    },

    closeOtherTabs(path) {
      this.tabs = this.tabs.filter(t => t.path === path || !t.closable)
      this.currentTab = path
    }
  }
})
