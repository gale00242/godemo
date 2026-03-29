<template>
  <div class="roles-page">
    <!-- 页面标题 -->
    <div class="page-header">
      <div class="page-title">
        <h2>{{ $t('menu.roleMgmt') }}</h2>
        <p>{{ $t('roles.desc') }}</p>
      </div>
      <el-button type="primary" class="btn-primary btn-icon-only" @click="handleAdd" :title="$t('common.add')">
        <svg class="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <line x1="12" y1="5" x2="12" y2="19"></line>
          <line x1="5" y1="12" x2="19" y2="12"></line>
        </svg>
      </el-button>
    </div>

    <!-- 角色表格 -->
    <div class="card">
      <el-table :data="roles" stripe v-loading="loading" class="roles-table">
        <el-table-column prop="id" label="ID" width="80" align="center" />
        <el-table-column prop="name" :label="$t('roles.name')" min-width="150">
          <template #default="{ row }">
            <div class="role-cell">
              <div class="role-icon" :class="getRoleClass(row.code)">
                <el-icon><Key /></el-icon>
              </div>
              <span class="role-name">{{ row.name }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="code" :label="$t('roles.code')" min-width="150">
          <template #default="{ row }">
            <code class="code-tag">{{ row.code }}</code>
          </template>
        </el-table-column>
        <el-table-column prop="description" :label="$t('roles.description')" min-width="200">
          <template #default="{ row }">
            <span class="text-muted">{{ row.description || '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="is_active" :label="$t('roles.status')" width="100" align="center">
          <template #default="{ row }">
            <span class="badge" :class="row.is_active ? 'badge-success' : 'badge-danger'">
              {{ row.is_active ? $t('users.active') : $t('users.inactive') }}
            </span>
          </template>
        </el-table-column>
        <el-table-column :label="$t('roles.actions')" width="140" align="center" fixed="right">
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

    <!-- 角色表单弹窗 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="500px"
      class="role-dialog"
      @close="handleDialogClose"
    >
      <el-form :model="roleForm" :rules="formRules" ref="formRef" label-width="100px">
        <el-form-item :label="$t('roles.name')" prop="name">
          <el-input v-model="roleForm.name" :placeholder="$t('roles.name')" />
        </el-form-item>
        <el-form-item :label="$t('roles.code')" prop="code">
          <el-input v-model="roleForm.code" :placeholder="$t('roles.code')" :disabled="!!roleForm.id" />
        </el-form-item>
        <el-form-item :label="$t('roles.description')" prop="description">
          <el-input v-model="roleForm.description" type="textarea" :rows="3" :placeholder="$t('roles.description')" />
        </el-form-item>
        <el-form-item :label="$t('roles.status')">
          <el-switch v-model="roleForm.is_active" />
          <span class="status-text">{{ roleForm.is_active ? $t('users.active') : $t('users.inactive') }}</span>
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
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Key } from '@element-plus/icons-vue'
import { useI18n } from 'vue-i18n'
import api from '../api'

const { t } = useI18n()
const roles = ref([])
const loading = ref(false)
const dialogVisible = ref(false)
const dialogTitle = ref(t('common.add'))
const submitting = ref(false)
const formRef = ref()

const roleForm = reactive({
  id: null,
  name: '',
  code: '',
  description: '',
  is_active: true
})

const formRules = {
  name: [{ required: true, message: t('roles.nameRequired'), trigger: 'blur' }],
  code: [{ required: true, message: t('roles.codeRequired'), trigger: 'blur' }],
}

const getRoleClass = (code) => {
  const map = {
    'super_admin': 'icon-danger',
    'admin': 'icon-warning',
    'operator': 'icon-success',
    'viewer': 'icon-info'
  }
  return map[code] || 'icon-info'
}

const loadRoles = async () => {
  loading.value = true
  try {
    const res = await api.getRoles()
    roles.value = res.data || []
  } catch (error) {
    console.error('加载角色失败:', error)
  } finally {
    loading.value = false
  }
}

const handleAdd = () => {
  dialogTitle.value = t('common.add')
  Object.assign(roleForm, { id: null, name: '', code: '', description: '', is_active: true })
  dialogVisible.value = true
}

const handleEdit = (row) => {
  dialogTitle.value = t('common.edit')
  Object.assign(roleForm, { ...row })
  dialogVisible.value = true
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(t('roles.deleteConfirm', { name: row.name }), t('common.confirm'), {
      confirmButtonText: t('common.confirm'), cancelButtonText: t('common.cancel'), type: 'warning'
    })
    await api.deleteRole(row.id)
    ElMessage.success(t('common.success'))
    loadRoles()
  } catch (error) {
    if (error !== 'cancel') ElMessage.error(t('common.error'))
  }
}

const handleSubmit = async () => {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  submitting.value = true
  try {
    if (roleForm.id) {
      await api.updateRole(roleForm.id, roleForm)
      ElMessage.success(t('common.success'))
    } else {
      await api.createRole(roleForm)
      ElMessage.success(t('common.success'))
    }
    dialogVisible.value = false
    loadRoles()
  } catch (error) {
    console.error('保存失败:', error)
  } finally {
    submitting.value = false
  }
}

const handleDialogClose = () => formRef.value?.resetFields()

onMounted(() => loadRoles())
</script>

<style scoped>
.roles-page { padding: 0; }

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

.roles-table { font-size: 14px; }
.roles-table :deep(.el-table__header th) {
  background: var(--bg-input);
  color: var(--text-secondary);
  font-weight: 600;
  font-size: 12px;
  text-transform: uppercase;
  padding: 14px 16px;
}
.roles-table :deep(.el-table__row:hover) { background: var(--bg-input); }

.role-cell { display: flex; align-items: center; gap: 12px; }
.role-icon {
  width: 36px;
  height: 36px;
  border-radius: var(--border-radius);
  display: flex;
  align-items: center;
  justify-content: center;
}
.role-icon .el-icon { font-size: 18px; color: white; }
.icon-danger { background: var(--gradient-danger); }
.icon-warning { background: var(--gradient-warning); }
.icon-success { background: var(--gradient-success); }
.icon-info { background: var(--gradient-primary); }

.role-name { font-weight: 600; color: var(--text-primary); }

.code-tag {
  background: var(--bg-input);
  padding: 4px 10px;
  border-radius: var(--border-radius-sm);
  font-size: 12px;
  color: var(--text-secondary);
  font-family: monospace;
}

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

.text-muted { color: var(--text-muted); font-size: 13px; }

/* 弹窗 */
.role-dialog :deep(.el-dialog__header) {
  border-bottom: 1px solid var(--border-default);
  padding: 20px 24px;
}
.role-dialog :deep(.el-dialog__title) {
  font-size: 18px;
  font-weight: 700;
  color: var(--text-primary);
}
.role-dialog :deep(.el-dialog__body) { padding: 24px; }
.role-dialog :deep(.el-dialog__footer) {
  border-top: 1px solid var(--border-default);
  padding: 16px 24px;
}

.status-text { margin-left: 12px; font-size: 14px; color: var(--text-secondary); }

.role-dialog :deep(.el-input__wrapper),
.role-dialog :deep(.el-textarea__inner) {
  border-radius: var(--border-radius);
}
</style>
