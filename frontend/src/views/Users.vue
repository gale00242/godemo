<template>
  <div class="users-page">
    <!-- 页面标题 -->
    <div class="page-header">
      <div class="page-title">
        <h2>{{ $t('menu.userMgmt') }}</h2>
        <p>{{ $t('users.desc') }}</p>
      </div>
      <el-button type="primary" class="btn-primary btn-icon-only" @click="handleAdd" :title="$t('common.add')">
        <svg class="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <line x1="12" y1="5" x2="12" y2="19"></line>
          <line x1="5" y1="12" x2="19" y2="12"></line>
        </svg>
      </el-button>
    </div>

    <!-- 搜索栏 -->
    <div class="search-bar">
      <el-input 
        v-model="searchKeyword" 
        :placeholder="$t('users.searchPlaceholder')" 
        class="search-input"
        clearable
        @clear="handleSearch"
        @keyup.enter="handleSearch"
      >
        <template #prefix>
          <el-icon><Search /></el-icon>
        </template>
      </el-input>
      <el-button type="primary" class="btn-search btn-icon-only" @click="handleSearch" :title="$t('common.search')">
        <svg class="btn-icon-small" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <circle cx="11" cy="11" r="8"></circle>
          <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
        </svg>
      </el-button>
    </div>

    <!-- 用户表格 -->
    <div class="card">
      <el-table 
        :data="users" 
        stripe 
        v-loading="loading"
        class="users-table"
      >
        <el-table-column prop="id" label="ID" width="80" align="center" />
        <el-table-column prop="username" :label="$t('users.username')" min-width="150">
          <template #default="{ row }">
            <div class="user-cell">
              <div class="user-avatar">
                {{ row.username?.charAt(0).toUpperCase() }}
              </div>
              <div class="user-info">
                <div class="user-name">{{ row.username }}</div>
                <div class="user-email">{{ row.email || '-' }}</div>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="phone" :label="$t('users.phone')" width="130">
          <template #default="{ row }">
            <span class="text-muted">{{ row.phone || '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="is_active" :label="$t('users.status')" width="100" align="center">
          <template #default="{ row }">
            <span class="badge" :class="row.is_active ? 'badge-success' : 'badge-danger'">
              {{ row.is_active ? $t('users.active') : $t('users.inactive') }}
            </span>
          </template>
        </el-table-column>
        <el-table-column prop="roles" :label="$t('users.roles')" min-width="180">
          <template #default="{ row }">
            <div class="tags-cell">
              <span 
                v-for="role in row.roles" 
                :key="role.id" 
                class="tag"
                :class="getRoleClass(role.code)"
              >
                {{ role.name }}
              </span>
              <span v-if="!row.roles?.length" class="text-muted">-</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="sites" :label="$t('login.site')" min-width="180">
          <template #default="{ row }">
            <div class="tags-cell">
              <span v-for="site in row.sites?.slice(0, 2)" :key="site.id" class="tag tag-info">
                {{ site.name }}
              </span>
              <span v-if="row.sites?.length > 2" class="tag tag-more">
                +{{ row.sites.length - 2 }}
              </span>
              <span v-if="!row.sites?.length" class="text-muted">-</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column :label="$t('users.actions')" width="140" align="center" fixed="right">
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

      <!-- 分页 -->
      <div class="pagination-wrapper">
        <div class="pagination-info">
          {{ $t('common.total', { count: pagination.total }) }}
        </div>
        <el-pagination
          v-model:current-page="pagination.page"
          v-model:page-size="pagination.pageSize"
          :page-sizes="[10, 20, 50, 100]"
          :total="pagination.total"
          layout="sizes, prev, pager, next"
          background
          @size-change="handleSizeChange"
          @current-change="handlePageChange"
        />
      </div>
    </div>

    <!-- 用户表单弹窗 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="500px"
      class="user-dialog"
      @close="handleDialogClose"
    >
      <el-form :model="userForm" :rules="formRules" ref="formRef" label-width="80px">
        <el-form-item :label="$t('users.username')" prop="username">
          <el-input 
            v-model="userForm.username" 
            :disabled="!!userForm.id" 
            :placeholder="$t('users.username')"
          />
        </el-form-item>

        <el-form-item :label="$t('login.password')" :prop="!userForm.id ? 'password' : ''">
          <el-input 
            v-model="userForm.password" 
            type="password" 
            show-password 
            :placeholder="userForm.id ? $t('users.passwordHint') : $t('login.password')"
          />
        </el-form-item>

        <el-form-item label="Email" prop="email">
          <el-input v-model="userForm.email" placeholder="Email" />
        </el-form-item>

        <el-form-item :label="$t('users.phone')" prop="phone">
          <el-input v-model="userForm.phone" :placeholder="$t('users.phone')" />
        </el-form-item>

        <el-form-item :label="$t('users.status')">
          <el-switch v-model="userForm.is_active" />
          <span class="status-text">{{ userForm.is_active ? $t('users.active') : $t('users.inactive') }}</span>
        </el-form-item>

        <el-form-item :label="$t('users.roles')">
          <el-select v-model="userForm.role_ids" multiple :placeholder="$t('users.selectRoles')" style="width: 100%">
            <el-option
              v-for="role in roles"
              :key="role.id"
              :label="role.name"
              :value="role.id"
            >
              <span>{{ role.name }}</span>
              <span class="option-code">{{ role.code }}</span>
            </el-option>
          </el-select>
        </el-form-item>

        <el-form-item :label="$t('login.site')">
          <el-select v-model="userForm.site_ids" multiple :placeholder="$t('login.selectSite')" style="width: 100%">
            <el-option
              v-for="site in sites"
              :key="site.id"
              :label="site.name"
              :value="site.id"
            >
              <span>{{ site.name }}</span>
              <span class="option-code">{{ site.code }}</span>
            </el-option>
          </el-select>
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
import { Search } from '@element-plus/icons-vue'
import { useI18n } from 'vue-i18n'
import api from '../api'

const { t } = useI18n()
const users = ref([])
const roles = ref([])
const sites = ref([])
const loading = ref(false)
const dialogVisible = ref(false)
const dialogTitle = ref(t('common.add'))
const submitting = ref(false)
const formRef = ref()
const searchKeyword = ref('')

const pagination = reactive({
  page: 1,
  pageSize: 10,
  total: 0
})

const userForm = reactive({
  id: null,
  username: '',
  password: '',
  email: '',
  phone: '',
  is_active: true,
  role_ids: [],
  site_ids: []
})

const formRules = {
  username: [{ required: true, message: t('users.usernameRequired'), trigger: 'blur' }],
  email: [{ type: 'email', message: t('users.emailInvalid'), trigger: 'blur' }],
}

const getRoleClass = (code) => {
  const map = {
    'super_admin': 'tag-danger',
    'admin': 'tag-warning',
    'operator': 'tag-success',
    'viewer': 'tag-info'
  }
  return map[code] || 'tag-info'
}

const loadUsers = async () => {
  loading.value = true
  try {
    const res = await api.getUsers(pagination.page, pagination.pageSize)
    users.value = res.data.items || []
    pagination.total = res.data.total || 0
  } catch (error) {
    console.error('加载用户失败:', error)
  } finally {
    loading.value = false
  }
}

const loadRolesAndSites = async () => {
  try {
    const [rolesRes, sitesRes] = await Promise.all([
      api.getRoles(),
      api.getAllSites()
    ])
    roles.value = rolesRes.data || []
    sites.value = sitesRes.data || []
  } catch (error) {
    console.error('加载角色/站点失败:', error)
  }
}

const handleSearch = () => {
  pagination.page = 1
  loadUsers()
}

const handleAdd = () => {
  dialogTitle.value = t('common.add')
  Object.assign(userForm, {
    id: null,
    username: '',
    password: '',
    email: '',
    phone: '',
    is_active: true,
    role_ids: [],
    site_ids: []
  })
  dialogVisible.value = true
}

const handleEdit = (row) => {
  dialogTitle.value = t('common.edit')
  Object.assign(userForm, {
    id: row.id,
    username: row.username,
    password: '',
    email: row.email || '',
    phone: row.phone || '',
    is_active: row.is_active,
    role_ids: row.roles?.map(r => r.id) || [],
    site_ids: row.sites?.map(s => s.id) || []
  })
  dialogVisible.value = true
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(
      t('users.deleteConfirm', { name: row.username }), 
      t('common.confirm'),
      { confirmButtonText: t('common.confirm'), cancelButtonText: t('common.cancel'), type: 'warning' }
    )
    await api.deleteUser(row.id)
    ElMessage.success(t('common.success'))
    loadUsers()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(t('common.error'))
    }
  }
}

const handleSubmit = async () => {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return

  submitting.value = true
  try {
    const data = { ...userForm }
    if (data.id && !data.password) {
      delete data.password
    }

    if (data.id) {
      await api.updateUser(data.id, data)
      ElMessage.success(t('common.success'))
    } else {
      await api.createUser(data)
      ElMessage.success(t('common.success'))
    }
    dialogVisible.value = false
    loadUsers()
  } catch (error) {
    console.error('保存失败:', error)
  } finally {
    submitting.value = false
  }
}

const handleDialogClose = () => {
  formRef.value?.resetFields()
}

const handlePageChange = (page) => {
  pagination.page = page
  loadUsers()
}

const handleSizeChange = (size) => {
  pagination.pageSize = size
  pagination.page = 1
  loadUsers()
}

onMounted(() => {
  loadUsers()
  loadRolesAndSites()
})
</script>

<style scoped>
.users-page {
  padding: 0;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.page-title h2 {
  font-size: 20px;
  font-weight: 700;
  color: var(--text-primary);
  margin-bottom: 4px;
}

.page-title p {
  font-size: 14px;
  color: var(--text-muted);
}

.btn-primary {
  background: var(--gradient-primary);
  border: none;
  box-shadow: 0 4px 14px rgba(91, 141, 239, 0.35);
}

.btn-primary:hover {
  transform: translateY(-1px);
  box-shadow: 0 6px 20px rgba(91, 141, 239, 0.45);
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

.search-bar {
  display: flex;
  gap: 12px;
  margin-bottom: 20px;
}

.search-input {
  width: 320px;
}

.search-input :deep(.el-input__wrapper) {
  border-radius: var(--border-radius);
}

.btn-search {
  background: var(--gradient-primary);
  border: none;
}

/* 卡片 */
.card {
  background: var(--bg-card);
  border-radius: var(--border-radius-lg);
  border: 1px solid var(--border-default);
  overflow: hidden;
}

/* 表格 */
.users-table {
  font-size: 14px;
}

.users-table :deep(.el-table__header th) {
  background: var(--bg-input);
  color: var(--text-secondary);
  font-weight: 600;
  font-size: 12px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  padding: 14px 16px;
}

.users-table :deep(.el-table__body td) {
  padding: 14px 16px;
  color: var(--text-secondary);
}

.users-table :deep(.el-table__row:hover) {
  background: var(--bg-input);
}

/* 用户单元格 */
.user-cell {
  display: flex;
  align-items: center;
  gap: 12px;
}

.user-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: var(--gradient-primary);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: 600;
  font-size: 14px;
  flex-shrink: 0;
}

.user-name {
  font-weight: 600;
  color: var(--text-primary);
}

.user-email {
  font-size: 12px;
  color: var(--text-muted);
}

/* 标签 */
.tags-cell {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.tag {
  display: inline-flex;
  padding: 3px 10px;
  font-size: 12px;
  font-weight: 500;
  border-radius: 20px;
}

.tag-danger { background: rgba(229, 62, 62, 0.1); color: var(--danger); }
.tag-warning { background: rgba(245, 166, 35, 0.1); color: #F5A623; }
.tag-success { background: rgba(72, 187, 120, 0.1); color: var(--success); }
.tag-info { background: var(--primary-soft); color: var(--primary); }
.tag-more { background: var(--bg-input); color: var(--text-muted); }

.badge {
  display: inline-flex;
  padding: 4px 10px;
  font-size: 12px;
  font-weight: 600;
  border-radius: 20px;
}

.badge-success { background: rgba(72, 187, 120, 0.1); color: var(--success); }
.badge-danger { background: rgba(229, 62, 62, 0.1); color: var(--danger); }

/* 操作按钮 */
.action-cell {
  display: flex;
  gap: 4px;
  justify-content: center;
}

/* 分页 */
.pagination-wrapper {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  border-top: 1px solid var(--border-default);
}

.pagination-info {
  font-size: 14px;
  color: var(--text-muted);
}

.text-muted {
  color: var(--text-muted);
  font-size: 13px;
}

/* 弹窗 */
.user-dialog :deep(.el-dialog__header) {
  border-bottom: 1px solid var(--border-default);
  padding: 20px 24px;
}

.user-dialog :deep(.el-dialog__title) {
  font-size: 18px;
  font-weight: 700;
  color: var(--text-primary);
}

.user-dialog :deep(.el-dialog__body) {
  padding: 24px;
}

.user-dialog :deep(.el-dialog__footer) {
  border-top: 1px solid var(--border-default);
  padding: 16px 24px;
}

.status-text {
  margin-left: 12px;
  font-size: 14px;
  color: var(--text-secondary);
}

.option-code {
  float: right;
  font-size: 11px;
  color: var(--text-muted);
  background: var(--bg-input);
  padding: 2px 6px;
  border-radius: 4px;
}

.user-dialog :deep(.el-input__wrapper),
.user-dialog :deep(.el-select .el-input__wrapper) {
  border-radius: var(--border-radius);
}
</style>
