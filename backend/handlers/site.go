package handlers

import (
	"net/http"

	"go-vue-admin/database"
	"go-vue-admin/models"

	"github.com/gin-gonic/gin"
)

func GetSites(c *gin.Context) {
	var sites []models.Site
	database.DB.Where("is_active = ?", true).Find(&sites)

	c.JSON(http.StatusOK, gin.H{
		"code": 200,
		"data": sites,
	})
}
