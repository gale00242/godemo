package handlers

import (
	"net/http"
	"sort"

	"go-vue-admin/database"
	"go-vue-admin/models"

	"github.com/gin-gonic/gin"
)

// MenuItem 菜单项
type MenuItem struct {
	ID       uint        `json:"id"`
	Name     string      `json:"name"`
	Path     string      `json:"path"`
	Icon     string      `json:"icon"`
	ParentID *uint       `json:"parent_id"`
	Sort     int         `json:"sort"`
	Children []*MenuItem `json:"children,omitempty"`
}

func GetMenus(c *gin.Context) {
	userID, _ := c.Get("user_id")

	var user models.User
	if err := database.DB.Preload("Roles.Menus").First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "用户不存在"})
		return
	}

	// 收集所有有权限的菜单，使用 map 存储指针以支持多层嵌套
	menuMap := make(map[uint]*MenuItem)
	for _, role := range user.Roles {
		for _, menu := range role.Menus {
			if menu.IsActive {
				if _, ok := menuMap[menu.ID]; !ok {
					menuMap[menu.ID] = &MenuItem{
						ID:       menu.ID,
						Name:     menu.Name,
						Path:     menu.Path,
						Icon:     menu.Icon,
						ParentID: menu.ParentID,
						Sort:     menu.Sort,
						Children: []*MenuItem{},
					}
				}
			}
		}
	}

	// 构建树形结构
	var result []*MenuItem
	for _, menu := range menuMap {
		if menu.ParentID == nil || *menu.ParentID == 0 {
			result = append(result, menu)
		} else {
			if parent, ok := menuMap[*menu.ParentID]; ok {
				parent.Children = append(parent.Children, menu)
			}
		}
	}

	// 递归排序
	sortMenus(result)

	c.JSON(http.StatusOK, gin.H{
		"code": 200,
		"data": result,
	})
}

func sortMenus(menus []*MenuItem) {
	sort.Slice(menus, func(i, j int) bool {
		return menus[i].Sort < menus[j].Sort
	})
	for _, m := range menus {
		if len(m.Children) > 0 {
			sortMenus(m.Children)
		}
	}
}
