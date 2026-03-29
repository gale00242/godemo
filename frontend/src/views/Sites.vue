<template>
  <div class="sites-page">
    <!-- 页面标题 -->
    <div class="page-header">
      <div class="page-title">
        <h2>{{ $t('menu.siteMgmt') }}</h2>
        <p>{{ $t('sites.desc') }}</p>
      </div>
      <el-button type="primary" class="btn-primary btn-icon-only" @click="handleAdd" :title="$t('common.add')">
        <svg class="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <line x1="12" y1="5" x2="12" y2="19"></line>
          <line x1="5" y1="12" x2="19" y2="12"></line>
        </svg>
      </el-button>
    </div>

    <!-- 站点表格 -->
    <div class="card">
      <el-table :data="sites" stripe v-loading="loading" class="sites-table">
        <el-table-column prop="id" label="ID" width="80" align="center" />
        <el-table-column prop="name" :label="$t('sites.name')" min-width="180">
          <template #default="{ row }">
            <div class="site-cell">
              <div class="site-icon">
                <el-icon><OfficeBuilding /></el-icon>
              </div>
              <span class="site-name">{{ row.name }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="code" :label="$t('sites.code')" width="150">
          <template #default="{ row }">
            <code class="code-tag">{{ row.code }}</code>
          </template>
        </el-table-column>
        <el-table-column prop="domain" :label="$t('sites.domain')" min-width="200">
          <template #default="{ row }">
            <a v-if="row.domain" :href="'http://' + row.domain" target="_blank" class="domain-link">
              {{ row.domain }}
            </a>
            <span v-else class="text-muted">-</span>
          </template>
        </el-table-column>
        <el-table-column prop="is_active" :label="$t('sites.status')" width="100" align="center">
          <template #default="{ row }">
            <span class="badge" :class="row.is_active ? 'badge-success' : 'badge-danger'">
              {{ row.is_active ? $t('users.active') : $t('users.inactive') }}
            </span>
          </template>
        </el-table-column>
        <el-table-column :label="$t('sites.actions')" width="140" align="center" fixed="right">
          <template #default="{ row }">
            <div class="action-cell">
              <el-button type="primary" text size="small" @click="handleEdit(row)" :title="$t('common.edit')">
                <svg class="btn-icon-small" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                  <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                </svg>
              </el-button>
              <el-button type="danger" text size="small" @click="handleDelete(row)" :title="$t('common.delete')">
                <svg class="btn-icon-small" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <polyline points="3 6 5 6 21 6"></polyline>
                  <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                </svg>
              </el-button>
            </div>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <!-- 站点表单弹窗 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="500px"
      class="site-dialog"
      @close="handleDialogClose"
    >
      <el-form :model="siteForm" :rules="formRules" ref="formRef" label-width="100px">
        <el-form-item :label="$t('sites.name')" prop="name">
          <el-input v-model="siteForm.name" :placeholder="$t('sites.name')" />
        </el-form-item>
        <el-form-item :label="$t('sites.code')" prop="code">
          <el-input v-model="siteForm.code" :placeholder="$t('sites.code')" :disabled="!!siteForm.id" />
        </el-form-item>
        <el-form-item :label="$t('sites.domain')" prop="domain">
          <el-input v-model="siteForm.domain" placeholder="example.com" />
        </el-form-item>
        <el-form-item :label="$t('sites.status')">
          <el-switch v-model="siteForm.is_active" />
          <span class="status-text">{{ siteForm.is_active ? $t('users.active') : $t('users.inactive') }}</span>
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="dialogVisible = false">{{ $t('common.cancel') }}</el-button>
        <el-button type="primary" class="btn-primary" @click="handleSubmit" :loading="submitting">
          {{ $t('common.confirm') }}
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { OfficeBuilding } from '@element-plus/icons-vue'
import { useI18n } from 'vue-i18n'
import api from '../api'

const { t } = useI18n()
const sites = ref([])
const loading = ref(false)
const dialogVisible = ref(false)
const submitting = ref(false)
const formRef = ref()

const dialogTitle = computed(() => siteForm.id ? t('common.edit') : t('common.add'))

const siteForm = reactive({
  id: null,
  name: '',
  code: '',
  domain: '',
  is_active: true
})

const formRules = computed(() => ({
  name: [{ required: true, message: t('sites.nameRequired'), trigger: 'blur' }],
  code: [{ required: true, message: t('sites.codeRequired'), trigger: 'blur' }],
}))

const loadSites = async () => {
  loading.value = true
  try {
    const res = await api.getAllSites()
    sites.value = res.data || []
  } catch (error) {
    console.error('加载站点失败:', error)
  } finally {
    loading.value = false
  }
}

const handleAdd = () => {
  Object.assign(siteForm, { id: null, name: '', code: '', domain: '', is_active: true })
  dialogVisible.value = true
}

const handleEdit = (row) => {
  Object.assign(siteForm, { ...row })
  dialogVisible.value = true
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(t('sites.deleteConfirm', { name: row.name }), t('common.confirm'), {
      confirmButtonText: t('common.confirm'), cancelButtonText: t('common.cancel'), type: 'warning'
    })
    await api.deleteSite(row.id)
    ElMessage.success(t('common.success'))
    loadSites()
  } catch (error) {
    if (error !== 'cancel') ElMessage.error(t('common.error'))
  }
}

const handleSubmit = async () => {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  submitting.value = true
  try {
    if (siteForm.id) {
      await api.updateSite(siteForm.id, siteForm)
      ElMessage.success(t('common.success'))
    } else {
      await api.createSite(siteForm)
      ElMessage.success(t('common.success'))
    }
    dialogVisible.value = false
    loadSites()
  } catch (error) {
    console.error('保存失败:', error)
  } finally {
    submitting.value = false
  }
}

const handleDialogClose = () => formRef.value?.resetFields()

onMounted(() => loadSites())
</script>

<style scoped>
.sites-page { padding: 0; }

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.btn-icon {
  width: 16px;
  height: 16px;
  vertical-align: middle;
}

.btn-icon-small {
  width: 14px;
  height: 14px;
  vertical-align: middle;
}

.btn-icon-only {
  padding: 8px;
  min-height: auto;
}

.page-title h2 { font-size: 20px; font-weight: 700; color: var(--text-primary); margin-bottom: 4px; }
.page-title p { font-size: 14px; color: var(--text-muted); }

.btn-primary {
  background: var(--gradient-primary);
  border: none;
  box-shadow: 0 4px 14px rgba(91, 141, 239, 0.35);
}

.card {
  background: var(--bg-card);
  border-radius: var(--border-radius-lg);
  border: 1px solid var(--border-default);
  overflow: hidden;
}

.sites-table { font-size: 14px; }
.sites-table :deep(.el-table__header th) {
  background: var(--bg-input);
  color: var(--text-secondary);
  font-weight: 600;
  font-size: 12px;
  text-transform: uppercase;
  padding: 14px 16px;
}
.sites-table :deep(.el-table__row:hover) { background: var(--bg-input); }

.site-cell { display: flex; align-items: center; gap: 12px; }
.site-icon {
  width: 36px;
  height: 36px;
  border-radius: var(--border-radius);
  background: var(--primary-soft);
  display: flex;
  align-items: center;
  justify-content: center;
}
.site-icon .el-icon { font-size: 18px; color: var(--primary); }

.site-name { font-weight: 600; color: var(--text-primary); }

.code-tag {
  background: var(--bg-input);
  padding: 4px 10px;
  border-radius: var(--border-radius-sm);
  font-size: 12px;
  color: var(--text-secondary);
  font-family: monospace;
}

.domain-link { color: var(--primary); text-decoration: none; }
.domain-link:hover { text-decoration: underline; }

.badge {
  display: inline-flex;
  padding: 4px 10px;
  font-size: 12px;
  font-weight: 600;
  border-radius: 20px;
}
.badge-success { background: rgba(72, 187, 120, 0.1); color: var(--success); }
.badge-danger { background: rgba(229, 62, 62, 0.1); color: var(--danger); }

.action-cell { display: flex; gap: 4px; justify-content: center; }

/* 弹窗 */
.site-dialog :deep(.el-dialog__header) {
  border-bottom: 1px solid var(--border-default);
  padding: 20px 24px;
}
.site-dialog :deep(.el-dialog__title) {
  font-size: 18px;
  font-weight: 700;
  color: var(--text-primary);
}
.site-dialog :deep(.el-dialog__body) { padding: 24px; }
.site-dialog :deep(.el-dialog__footer) {
  border-top: 1px solid var(--border-default);
  padding: 16px 24px;
}

.status-text { margin-left: 12px; font-size: 14px; color: var(--text-secondary); }

.site-dialog :deep(.el-input__wrapper) {
  border-radius: var(--border-radius);
}
</style>
