package config

import (
	"fmt"
	"os"
	"strconv"
)

type Config struct {
	DBHost     string
	DBPort     int
	DBUser     string
	DBPassword string
	DBName     string
	JWTSecret  string
	ServerPort string
}

var AppConfig *Config

func LoadConfig() {
	// 从环境变量读取，带默认值
	dbHost := getEnv("DB_HOST", "mysql")
	dbPort, _ := strconv.Atoi(getEnv("DB_PORT", "3306"))
	dbUser := getEnv("DB_USER", "root")
	dbPassword := getEnv("DB_PASSWORD", "root123")
	dbName := getEnv("DB_NAME", "go_vue_admin")
	jwtSecret := getEnv("JWT_SECRET", "your-super-secret-key-change-in-production")
	serverPort := getEnv("SERVER_PORT", "8080")

	AppConfig = &Config{
		DBHost:     dbHost,
		DBPort:     dbPort,
		DBUser:     dbUser,
		DBPassword: dbPassword,
		DBName:     dbName,
		JWTSecret:  jwtSecret,
		ServerPort: serverPort,
	}

	fmt.Printf("数据库配置: host=%s, port=%d, db=%s\n", dbHost, dbPort, dbName)
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
