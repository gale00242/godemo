import axios from 'axios'
import { ElMessage } from 'element-plus'

const api = axios.create({
  baseURL: '/api',
  timeout: 10000,
})

api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => Promise.reject(error)
)

api.interceptors.response.use(
  (response) => {
    if (response.data.code !== 200) {
      ElMessage.error(response.data.message)
      return Promise.reject(response.data)
    }
    return response.data
  },
  (error) => {
    if (error.response?.status === 401) {
      ElMessage.error('登录已过期，请重新登录')
      localStorage.removeItem('token')
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

export default {
  // 登录
  login(data) {
    return api.post('/auth/login', data)
  },
  
  // 当前用户
  getCurrentUser() {
    return api.get('/auth/user')
  },
  
  // 菜单
  getMenus() {
    return api.get('/menus')
  },
  
  // 站点（公开）
  getSites() {
    return api.get('/sites/public')
  },
  
  // 用户管理
  getUsers(page = 1, pageSize = 10) {
    return api.get('/users', { params: { page, page_size: pageSize } })
  },
  getUser(id) {
    return api.get(`/users/${id}`)
  },
  createUser(data) {
    return api.post('/users', data)
  },
  updateUser(id, data) {
    return api.put(`/users/${id}`, data)
  },
  deleteUser(id) {
    return api.delete(`/users/${id}`)
  },
  
  // 角色管理
  getRoles() {
    return api.get('/roles')
  },
  getRole(id) {
    return api.get(`/roles/${id}`)
  },
  createRole(data) {
    return api.post('/roles', data)
  },
  updateRole(id, data) {
    return api.put(`/roles/${id}`, data)
  },
  deleteRole(id) {
    return api.delete(`/roles/${id}`)
  },
  
  // 站点管理
  getAllSites() {
    return api.get('/all-sites')
  },
  getSite(id) {
    return api.get(`/sites/${id}`)
  },
  createSite(data) {
    return api.post('/sites', data)
  },
  updateSite(id, data) {
    return api.put(`/sites/${id}`, data)
  },
  deleteSite(id) {
    return api.delete(`/sites/${id}`)
  },
}
