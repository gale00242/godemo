package middleware

import (
	"net/http"
	"sync"

	"go-vue-admin/database"
	"go-vue-admin/models"

	"github.com/gin-gonic/gin"
)

// 使用 sync.Map 作为简单的本地内存缓存，存储 userID -> []string{allowedPaths}
var userPermissionsCache sync.Map

// ClearUserCache 清除特定用户的权限缓存（当权限变更时调用）
func ClearUserCache(userID uint) {
	userPermissionsCache.Delete(userID)
}

// ClearAllCache 清除所有权限缓存（当角色权限大范围变动时调用）
func ClearAllCache() {
	userPermissionsCache.Range(func(key, value interface{}) bool {
		userPermissionsCache.Delete(key)
		return true
	})
}

// CheckPermission 动态权限校验中间件（带内存缓存优化）
func CheckPermission(requiredPath string) gin.HandlerFunc {
	return func(c *gin.Context) {
		userIDInterface, exists := c.Get("user_id")
		if !exists {
			c.JSON(http.StatusUnauthorized, gin.H{"code": 401, "message": "未登录"})
			c.Abort()
			return
		}
		userID := userIDInterface.(uint)

		// 1. 尝试从缓存获取权限列表
		var allowedPaths []string
		if val, ok := userPermissionsCache.Load(userID); ok {
			allowedPaths = val.([]string)
		} else {
			// 2. 缓存未命中，从数据库加载并存入缓存
			var user models.User
			if err := database.DB.Preload("Roles").First(&user, userID).Error; err != nil {
				c.JSON(http.StatusForbidden, gin.H{"code": 403, "message": "获取用户信息失败"})
				c.Abort()
				return
			}

			// 超级管理员豁免：缓存中存入特殊标识或直接放行
			for _, role := range user.Roles {
				if role.Code == "admin" {
					c.Next()
					return
				}
			}

			// 查询该用户拥有的所有活跃菜单路径
			database.DB.Table("users").
				Joins("JOIN user_roles ON user_roles.user_id = users.id").
				Joins("JOIN role_menus ON role_menus.role_id = user_roles.role_id").
				Joins("JOIN menus ON menus.id = role_menus.menu_id").
				Where("users.id = ? AND menus.is_active = ?", userID, true).
				Pluck("menus.path", &allowedPaths)

			// 写入缓存
			userPermissionsCache.Store(userID, allowedPaths)
		}

		// 3. 判断当前路径是否在允许列表中
		hasPermission := false
		for _, path := range allowedPaths {
			if path == requiredPath {
				hasPermission = true
				break
			}
		}

		if !hasPermission {
			c.JSON(http.StatusForbidden, gin.H{
				"code":    403,
				"message": "权限不足 [" + requiredPath + "]",
			})
			c.Abort()
			return
		}

		c.Next()
	}
}
