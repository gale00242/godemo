package database

import (
	"fmt"
	"log"
	"time"

	"go-vue-admin/config"
	"gorm.io/driver/sqlserver"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
	"net/url"
)

var DB *gorm.DB

func InitDatabase() {
	// 对密码进行 URL 编码，防止特殊字符导致 DSN 解析失败
	encodedPassword := url.QueryEscape(config.AppConfig.DBPassword)
	dsn := fmt.Sprintf("sqlserver://%s:%s@%s:%d?database=%s",
		config.AppConfig.DBUser,
		encodedPassword,
		config.AppConfig.DBHost,
		config.AppConfig.DBPort,
		config.AppConfig.DBName,
	)

	var err error
	DB, err = gorm.Open(sqlserver.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		log.Fatal("数据库连接失败:", err)
	}

	sqlDB, _ := DB.DB()
	sqlDB.SetMaxIdleConns(10)
	sqlDB.SetMaxOpenConns(100)
	sqlDB.SetConnMaxLifetime(time.Hour)
}
