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

		// 用户管理
		authGroup.GET("/users", handlers.GetUsers)
		authGroup.GET("/users/:id", handlers.GetUser)
		authGroup.POST("/users", handlers.CreateUser)
		authGroup.PUT("/users/:id", handlers.UpdateUser)
		authGroup.DELETE("/users/:id", handlers.DeleteUser)

		// 角色管理
		authGroup.GET("/roles", handlers.GetRoles)
		authGroup.GET("/roles/:id", handlers.GetRole)
		authGroup.POST("/roles", handlers.CreateRole)
		authGroup.PUT("/roles/:id", handlers.UpdateRole)
		authGroup.DELETE("/roles/:id", handlers.DeleteRole)

		// 站点管理
		authGroup.GET("/all-sites", handlers.GetAllSites)
		authGroup.GET("/sites/:id", handlers.GetSite)
		authGroup.POST("/sites", handlers.CreateSite)
		authGroup.PUT("/sites/:id", handlers.UpdateSite)
		authGroup.DELETE("/sites/:id", handlers.DeleteSite)
	}

	log.Printf("服务器启动在 :%s", config.AppConfig.ServerPort)
	r.Run(":" + config.AppConfig.ServerPort)
}
