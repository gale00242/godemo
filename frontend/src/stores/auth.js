import { defineStore } from 'pinia'
import api from '../api'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: localStorage.getItem('token') || '',
    userInfo: null,
    sites: [],
    currentSite: localStorage.getItem('site_code') || 'site-a',
    permissions: []
  }),
  actions: {
    setToken(token) {
      this.token = token
      localStorage.setItem('token', token)
    },
    setUserInfo(userInfo) {
      this.userInfo = userInfo
      if (userInfo?.roles) {
        this.permissions = userInfo.roles.flatMap(r => r.permissions || [])
      }
    },
    setSites(sites) {
      this.sites = sites
    },
    setCurrentSite(siteCode) {
      this.currentSite = siteCode
      localStorage.setItem('site_code', siteCode)
    },
    logout() {
      this.token = ''
      this.userInfo = null
      this.permissions = []
      localStorage.removeItem('token')
      localStorage.removeItem('site_code')
    },
    async login(loginForm) {
      const res = await api.login(loginForm)
      this.token = res.data.token
      this.userInfo = res.data
      this.currentSite = loginForm.site_code
      localStorage.setItem('token', res.data.token)
      localStorage.setItem('site_code', loginForm.site_code)
      return res
    }
  }
})
