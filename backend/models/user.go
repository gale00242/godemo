package models

type User struct {
	ID        uint   `json:"id" gorm:"primaryKey"`
	Username  string `json:"username" gorm:"uniqueIndex;size:64;not null"`
	Password  string `json:"-" gorm:"size:256;not null"`
	Email     string `json:"email" gorm:"size:128"`
	Phone     string `json:"phone" gorm:"size:32"`
	IsActive  bool   `json:"is_active" gorm:"default:true"`
	Roles     []Role `json:"roles" gorm:"many2many:user_roles"`
	Sites     []Site `json:"sites" gorm:"many2many:user_sites"`
}

func (User) TableName() string {
	return "users"
}

type UserSite struct {
	UserID uint `json:"user_id" gorm:"primaryKey"`
	SiteID uint `json:"site_id" gorm:"primaryKey"`
}

func (UserSite) TableName() string {
	return "user_sites"
}

type UserRole struct {
	UserID uint `json:"user_id" gorm:"primaryKey"`
	RoleID uint `json:"role_id" gorm:"primaryKey"`
}

func (UserRole) TableName() string {
	return "user_roles"
}

type RoleMenu struct {
	RoleID uint `json:"role_id" gorm:"primaryKey"`
	MenuID uint `json:"menu_id" gorm:"primaryKey"`
}

func (RoleMenu) TableName() string {
	return "role_menus"
}
