package main

import (
	"log"
	"os"
	"strings"

	"go-vue-admin/config"
	"go-vue-admin/database"
	"go-vue-admin/handlers"
	"go-vue-admin/middleware"
	"go-vue-admin/models"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func main() {
	config.LoadConfig()
	database.InitDatabase()
	database.DB.AutoMigrate(&models.Site{}, &models.User{}, &models.Role{}, &models.Menu{}, &models.UserSite{}, &models.UserRole{}, &models.RoleMenu{})

	r := gin.Default()

	allowOrigins := []string{"*"}
	if origins := os.Getenv("ALLOW_ORIGINS"); origins != "" {
		allowOrigins = strings.Split(origins, ",")
	}

	r.Use(cors.New(cors.Config{
		AllowOrigins:     allowOrigins,
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
		AllowCredentials: true,
	}))

	// 公开接口
	r.POST("/api/auth/login", handlers.Login)
	r.GET("/api/sites/public", handlers.GetSites)

	// 需要认证的接口
	authGroup := r.Group("/api")
	authGroup.Use(middleware.JWTAuth())
	{
		authGroup.GET("/auth/user", handlers.GetCurrentUser)
		authGroup.GET("/menus", handlers.GetMenus)

		// 权限校验逻辑应用：
		// 使用 middleware.CheckPermission("菜单路径") 来动态拦截

		// 1. 用户管理 (关联菜单路径: /users)
		userPerm := middleware.CheckPermission("/users")
		authGroup.GET("/users", userPerm, handlers.GetUsers)
		authGroup.GET("/users/:id", userPerm, handlers.GetUser)
		authGroup.POST("/users", userPerm, handlers.CreateUser)
		authGroup.PUT("/users/:id", userPerm, handlers.UpdateUser)
		authGroup.DELETE("/users/:id", userPerm, handlers.DeleteUser)

		// 2. 角色管理 (关联菜单路径: /roles)
		rolePerm := middleware.CheckPermission("/roles")
		authGroup.GET("/roles", rolePerm, handlers.GetRoles)
		authGroup.GET("/roles/:id", rolePerm, handlers.GetRole)
		authGroup.POST("/roles", rolePerm, handlers.CreateRole)
		authGroup.PUT("/roles/:id", rolePerm, handlers.UpdateRole)
		authGroup.DELETE("/roles/:id", rolePerm, handlers.DeleteRole)
		authGroup.GET("/roles/:id/menus", rolePerm, handlers.GetRoleMenus)
		authGroup.POST("/roles/:id/menus", rolePerm, handlers.UpdateRoleMenus)

		// 获取所有菜单用于分配权限
		authGroup.GET("/all-menus", rolePerm, handlers.GetAllMenus)

		// 3. 站点管理 (关联菜单路径: /sites)
		sitePerm := middleware.CheckPermission("/sites")
		authGroup.GET("/all-sites", sitePerm, handlers.GetAllSites)
		authGroup.GET("/sites/:id", sitePerm, handlers.GetSite)
		authGroup.POST("/sites", sitePerm, handlers.CreateSite)
		authGroup.PUT("/sites/:id", sitePerm, handlers.UpdateSite)
		authGroup.DELETE("/sites/:id", sitePerm, handlers.DeleteSite)
	}

	log.Printf("服务器启动在 :%s", config.AppConfig.ServerPort)
	r.Run(":" + config.AppConfig.ServerPort)
}
