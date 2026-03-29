import { createI18n } from 'vue-i18n'
import zhCN from './zh-CN'
import enUS from './en-US'

const i18n = createI18n({
  legacy: false, // 使用 Composition API
  locale: localStorage.getItem('locale') || 'zh-CN',
  fallbackLocale: 'en-US',
  globalInjection: true, // 全局注入 $t
  messages: {
    'zh-CN': zhCN,
    'en-US': enUS,
  },
})

export default i18n
