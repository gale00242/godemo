package models

type Site struct {
	ID        uint   `json:"id" gorm:"primaryKey"`
	Name      string `json:"name" gorm:"size:128;not null"`
	Code      string `json:"code" gorm:"uniqueIndex;size:64;not null"`
	Domain    string `json:"domain" gorm:"size:256"`
	IsActive  bool   `json:"is_active" gorm:"default:true"`
}

func (Site) TableName() string {
	return "sites"
}

type Role struct {
	ID          uint   `json:"id" gorm:"primaryKey"`
	Name        string `json:"name" gorm:"size:64;not null"`
	Code        string `json:"code" gorm:"uniqueIndex;size:64;not null"`
	Description string `json:"description" gorm:"size:256"`
	IsActive    bool   `json:"is_active" gorm:"default:true"`
	Menus       []Menu `json:"menus" gorm:"many2many:role_menus"`
}

func (Role) TableName() string {
	return "roles"
}

type Menu struct {
	ID       uint  `json:"id" gorm:"primaryKey"`
	Name     string `json:"name" gorm:"size:64;not null"`
	Path     string `json:"path" gorm:"size:128"`
	Icon     string `json:"icon" gorm:"size:64"`
	ParentID *uint  `json:"parent_id" gorm:"index"`
	Sort     int    `json:"sort" gorm:"default:0"`
	IsActive bool   `json:"is_active" gorm:"default:true"`
}

func (Menu) TableName() string {
	return "menus"
}
