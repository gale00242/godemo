<template>
  <div class="login-page">
    <!-- 语言切换 -->
    <div class="lang-switch">
      <el-dropdown @command="handleLanguageChange" trigger="click">
        <div class="lang-btn">
          <el-icon><Bell /></el-icon>
          <span>{{ currentLocale === 'zh-CN' ? '中文' : 'English' }}</span>
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
    </div>

    <!-- 左侧装饰区域 -->
    <div class="left-panel">
      <div class="deco-circle c1"></div>
      <div class="deco-circle c2"></div>
      <div class="deco-circle c3"></div>
      <div class="deco-circle c4"></div>
      
      <div class="deco-icons">
        <div class="deco-icon">📊</div>
        <div class="deco-icon">🎨</div>
        <div class="deco-icon">✨</div>
        <div class="deco-icon">🔧</div>
        <div class="deco-icon">🚀</div>
        <div class="deco-icon">💡</div>
        <div class="deco-icon">📱</div>
        <div class="deco-icon">⚡</div>
        <div class="deco-icon">🎯</div>
      </div>
    </div>

    <!-- 右侧登录表单 -->
    <div class="right-panel">
      <div class="login-card">
        <!-- Logo -->
        <div class="logo-area">
          <div class="logo-icon">A</div>
          <span class="logo-text">AdminSystem</span>
        </div>

        <!-- 标题 -->
        <div class="header">
          <h1>{{ $t('login.welcomeBack') }}</h1>
          <p>{{ $t('login.loginDesc') }}</p>
        </div>

        <!-- 表单 -->
        <el-form
          ref="loginFormRef"
          :model="loginForm"
          :rules="rules"
          class="login-form"
        >
          <el-form-item prop="site_code">
            <label class="form-label">{{ $t('login.site') }}</label>
            <el-select
              v-model="loginForm.site_code"
              :placeholder="$t('login.selectSite')"
              size="large"
              style="width: 100%"
            >
              <el-option
                v-for="site in sites"
                :key="site.code"
                :label="site.name"
                :value="site.code"
              >
                <div class="site-option">
                  <span>{{ site.name }}</span>
                  <code>{{ site.code }}</code>
                </div>
              </el-option>
            </el-select>
          </el-form-item>

          <el-form-item prop="username">
            <label class="form-label">{{ $t('login.username') }}</label>
            <el-input
              v-model="loginForm.username"
              :placeholder="$t('login.username')"
              size="large"
            />
          </el-form-item>

          <el-form-item prop="password">
            <label class="form-label">{{ $t('login.password') }}</label>
            <el-input
              v-model="loginForm.password"
              type="password"
              :placeholder="$t('login.password')"
              size="large"
              show-password
              @keyup.enter="handleLogin"
            />
          </el-form-item>

          <div class="form-options">
            <label class="remember-me">
              <input type="checkbox" v-model="rememberMe">
              <span>{{ $t('login.rememberMe') }}</span>
            </label>
          </div>

          <el-button
            type="primary"
            size="large"
            :loading="loading"
            class="btn-primary"
            @click="handleLogin"
          >
            {{ loading ? $t('login.logging') : $t('login.loginBtn') }}
          </el-button>
        </el-form>

        <div class="login-footer">
          <span>默认账号：admin / 123456</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useAuthStore } from '../stores/auth'
import { useI18n } from 'vue-i18n'
import { Bell } from '@element-plus/icons-vue'
import api from '../api'

const { locale } = useI18n()
const router = useRouter()
const authStore = useAuthStore()

const loginFormRef = ref()
const loading = ref(false)
const rememberMe = ref(false)
const sites = ref([])
const currentLocale = ref(localStorage.getItem('locale') || 'zh-CN')

const loginForm = reactive({
  site_code: 'site-a',
  username: '',
  password: ''
})

const rules = {
  site_code: [{ required: true, message: '请选择站点', trigger: 'change' }],
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

const loadSites = async () => {
  try {
    const res = await api.getSites()
    sites.value = res.data
    if (sites.value.length > 0) {
      loginForm.site_code = sites.value[0].code
    }
  } catch (error) {
    console.error('加载站点失败:', error)
  }
}

const handleLogin = async () => {
  const valid = await loginFormRef.value.validate().catch(() => false)
  if (!valid) return

  loading.value = true
  try {
    await authStore.login(loginForm)
    
    // 强制持久化语言选择
    localStorage.setItem('locale', currentLocale.value)
    locale.value = currentLocale.value
    
    ElMessage.success('登录成功')
    router.push('/')
  } catch (error) {
    ElMessage.error('登录失败，请检查用户名和密码')
  } finally {
    loading.value = false
  }
}

const handleLanguageChange = (lang) => {
  currentLocale.value = lang
  localStorage.setItem('locale', lang)
  locale.value = lang
}

onMounted(() => {
  loadSites()
})
</script>

<style>
:root {
  --primary: #5B8DEF;
  --primary-light: #8FADFF;
  --primary-dark: #3D6DD4;
  --gradient-start: #5B8DEF;
  --gradient-end: #7EC5FF;
  --bg-main: #EEF2F8;
  --bg-card: #FFFFFF;
  --bg-input: #F8FAFC;
  --border-default: #D8E0EC;
  --border-focus: #5B8DEF;
  --border-hover: #B0BDD0;
  --text-primary: #1A2332;
  --text-secondary: #4A5568;
  --text-muted: #8896A8;
  --text-link: #5B8DEF;
  --deco-violet: #8B7CF7;
  --deco-cyan: #38D4E0;
  --deco-pink: #F78FB3;
  --deco-orange: #F5A623;
}

* { margin: 0; padding: 0; box-sizing: border-box; }
body { font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif; }
</style>

<style scoped>
.login-page {
  min-height: 100vh;
  display: flex;
  position: relative;
}

.lang-switch {
  position: absolute;
  top: 30px;
  right: 30px;
  z-index: 1000;
}

.lang-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 20px;
  background: var(--primary);
  color: white;
  border-radius: 20px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.15);
  cursor: pointer;
  font-size: 14px;
  transition: all 0.2s;
}

.lang-btn:hover {
  background: var(--primary-dark);
  transform: translateY(-1px);
}

/* 左侧装饰区域 */
.left-panel {
  flex: 1;
  background: linear-gradient(135deg, var(--gradient-start) 0%, var(--gradient-end) 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
  min-height: 100vh;
}

.deco-circle {
  position: absolute;
  border-radius: 50%;
  opacity: 0.15;
}

.deco-circle.c1 {
  width: 400px;
  height: 400px;
  background: var(--deco-violet);
  top: -100px;
  left: -100px;
}

.deco-circle.c2 {
  width: 300px;
  height: 300px;
  background: var(--deco-cyan);
  bottom: -50px;
  right: -50px;
}

.deco-circle.c3 {
  width: 200px;
  height: 200px;
  background: var(--deco-pink);
  top: 50%;
  left: 20%;
}

.deco-circle.c4 {
  width: 150px;
  height: 150px;
  background: var(--deco-orange);
  bottom: 30%;
  right: 10%;
}

.deco-icons {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 80px;
  position: relative;
  z-index: 1;
}

.deco-icon {
  width: 80px;
  height: 80px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32px;
  backdrop-filter: blur(4px);
  border: 1px solid rgba(255, 255, 255, 0.3);
}

/* 右侧登录区域 */
.right-panel {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 60px;
  min-height: 100vh;
  background: var(--bg-main);
}

.login-card {
  width: 100%;
  max-width: 420px;
}

.logo-area {
  margin-bottom: 48px;
  display: flex;
  align-items: center;
  gap: 12px;
}

.logo-icon {
  width: 44px;
  height: 44px;
  background: linear-gradient(135deg, var(--gradient-start), var(--gradient-end));
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: 700;
  font-size: 20px;
}

.logo-text {
  font-size: 22px;
  font-weight: 700;
  color: var(--text-primary);
}

.header {
  margin-bottom: 36px;
}

.header h1 {
  font-size: 28px;
  font-weight: 700;
  color: var(--text-primary);
  margin-bottom: 8px;
}

.header p {
  font-size: 15px;
  color: var(--text-muted);
}

/* 表单样式 */
.login-form {
  margin-bottom: 24px;
}

.form-label {
  display: block;
  font-size: 13px;
  font-weight: 600;
  color: var(--text-secondary);
  margin-bottom: 8px;
}

.login-form :deep(.el-input__wrapper) {
  background: var(--bg-input);
  border: 1.5px solid var(--border-default);
  border-radius: 10px;
  box-shadow: none;
  padding: 4px 16px;
}

.login-form :deep(.el-input__wrapper:hover) {
  border-color: var(--border-hover);
}

.login-form :deep(.el-input__wrapper.is-focus) {
  border-color: var(--border-focus);
  box-shadow: 0 0 0 3px rgba(91, 141, 239, 0.12);
}

.login-form :deep(.el-input__inner) {
  height: 44px;
  font-size: 15px;
}

.login-form :deep(.el-select .el-input__wrapper) {
  padding-right: 40px;
}

.form-options {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 28px;
}

.remember-me {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}

.remember-me input {
  width: 18px;
  height: 18px;
  accent-color: var(--primary);
  cursor: pointer;
}

.remember-me span {
  font-size: 14px;
  color: var(--text-secondary);
}

.btn-primary {
  width: 100%;
  padding: 15px;
  font-size: 15px;
  font-weight: 600;
  color: white;
  background: linear-gradient(135deg, var(--gradient-start) 0%, var(--gradient-end) 100%);
  border: none;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: 0 4px 14px rgba(91, 141, 239, 0.35);
}

.btn-primary:hover {
  transform: translateY(-1px);
  box-shadow: 0 6px 20px rgba(91, 141, 239, 0.45);
}

.login-footer {
  text-align: center;
  font-size: 13px;
  color: var(--text-muted);
  margin-top: 24px;
}

.site-option {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.site-option code {
  font-size: 11px;
  color: var(--text-muted);
  background: var(--bg-input);
  padding: 2px 6px;
  border-radius: 4px;
}

/* 响应式 */
@media (max-width: 900px) {
  .login-page {
    flex-direction: column;
  }
  
  .left-panel {
    min-height: 200px;
    padding: 40px;
  }
  
  .deco-icons {
    gap: 40px;
  }
  
  .deco-icon {
    width: 60px;
    height: 60px;
    font-size: 24px;
  }
  
  .right-panel {
    padding: 40px 24px;
  }
}
</style>
