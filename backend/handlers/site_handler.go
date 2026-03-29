package handlers

import (
	"net/http"
	"strconv"

	"go-vue-admin/database"
	"go-vue-admin/models"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type CreateSiteRequest struct {
	Name     string `json:"name" binding:"required"`
	Code     string `json:"code" binding:"required"`
	Domain   string `json:"domain"`
	IsActive *bool  `json:"is_active"`
}

type UpdateSiteRequest struct {
	Name     string `json:"name"`
	Domain   string `json:"domain"`
	IsActive *bool  `json:"is_active"`
}

func GetAllSites(c *gin.Context) {
	var sites []models.Site
	database.DB.Where("is_active = ?", true).Find(&sites)

	c.JSON(http.StatusOK, gin.H{
		"code": 200,
		"data": sites,
	})
}

func GetSite(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	var site models.Site
	if err := database.DB.First(&site, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "站点不存在"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code": 200,
		"data": site,
	})
}

func CreateSite(c *gin.Context) {
	var req CreateSiteRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "参数错误"})
		return
	}

	// 检查code是否存在
	var existing models.Site
	if err := database.DB.Where("code = ?", req.Code).First(&existing).Error; err == nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "站点代码已存在"})
		return
	}

	isActive := true
	if req.IsActive != nil {
		isActive = *req.IsActive
	}

	site := models.Site{
		Name:     req.Name,
		Code:     req.Code,
		Domain:   req.Domain,
		IsActive: isActive,
	}

	if err := database.DB.Create(&site).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "创建站点失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "创建成功",
		"data":    site,
	})
}

func UpdateSite(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	var site models.Site
	if err := database.DB.First(&site, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "站点不存在"})
		return
	}

	var req UpdateSiteRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "参数错误"})
		return
	}

	if req.Name != "" {
		site.Name = req.Name
	}
	if req.Domain != "" {
		site.Domain = req.Domain
	}
	if req.IsActive != nil {
		site.IsActive = *req.IsActive
	}

	if err := database.DB.Save(&site).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "更新站点失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "更新成功",
		"data":    site,
	})
}

func DeleteSite(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	var site models.Site
	if err := database.DB.First(&site, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "站点不存在"})
		return
	}

	err := database.DB.Transaction(func(tx *gorm.DB) error {
		// 清除用户关联
		if err := tx.Where("site_id = ?", id).Delete(&models.UserSite{}).Error; err != nil {
			return err
		}

		if err := tx.Delete(&site).Error; err != nil {
			return err
		}
		return nil
	})

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "删除站点失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "删除成功",
	})
}
