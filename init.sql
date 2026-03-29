SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- 初始化数据

CREATE DATABASE IF NOT EXISTS go_vue_admin;
USE go_vue_admin;

-- 站点表
CREATE TABLE IF NOT EXISTS `sites` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL,
  `code` varchar(64) NOT NULL,
  `domain` varchar(256) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_sites_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 用户表
CREATE TABLE IF NOT EXISTS `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) NOT NULL,
  `password` varchar(256) NOT NULL,
  `email` varchar(128) DEFAULT NULL,
  `phone` varchar(32) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_users_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 角色表
CREATE TABLE IF NOT EXISTS `roles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `code` varchar(64) NOT NULL,
  `description` varchar(256) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_roles_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 菜单表 (名称改为国际化 Key)
CREATE TABLE IF NOT EXISTS `menus` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `path` varchar(128) DEFAULT NULL,
  `icon` varchar(64) DEFAULT NULL,
  `parent_id` bigint unsigned DEFAULT NULL,
  `sort` bigint DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `idx_menus_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 中间表
CREATE TABLE IF NOT EXISTS `user_sites` (
  `user_id` bigint unsigned NOT NULL,
  `site_id` bigint unsigned NOT NULL,
  PRIMARY KEY (`user_id`,`site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `user_roles` (
  `user_id` bigint unsigned NOT NULL,
  `role_id` bigint unsigned NOT NULL,
  PRIMARY KEY (`user_id`,`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `role_menus` (
  `role_id` bigint unsigned NOT NULL,
  `menu_id` bigint unsigned NOT NULL,
  PRIMARY KEY (`role_id`,`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 站点数据
INSERT IGNORE INTO sites (id, name, code, domain) VALUES 
(1, '站点A', 'site-a', 'a.example.com'),
(2, '站点B', 'site-b', 'b.example.com'),
(3, '站点C', 'site-c', 'c.example.com');

-- 用户表 (密码是 123456 的 bcrypt 加密)
INSERT IGNORE INTO users (id, username, password, email, phone, is_active) VALUES 
(1, 'admin', '$2a$12$ESF0L2ZF1RD75T3nb2AZXuxO0L4Jb1VVYdqkN4AXur1ipF1IvIAam', 'admin@example.com', '13800138000', 1);

-- 角色表
INSERT IGNORE INTO roles (id, name, code, description, is_active) VALUES 
(1, '超级管理员', 'super_admin', '拥有所有权限', 1);

-- 菜单表 (关键改动：使用国际化 Key 存储名称)
INSERT IGNORE INTO menus (id, name, path, icon, parent_id, sort, is_active) VALUES 
(1, 'menu.home', '/home', 'HomeFilled', 0, 1, 1),
(100, 'menu.systemSettings', '/settings', 'Setting', 0, 100, 1),
(101, 'menu.userMgmt', '/users', 'User', 100, 101, 1),
(102, 'menu.roleMgmt', '/roles', 'Key', 100, 102, 1),
(103, 'menu.siteMgmt', '/sites', 'OfficeBuilding', 100, 103, 1);

-- 权限分配
INSERT IGNORE INTO role_menus (role_id, menu_id) SELECT 1, id FROM menus;
INSERT IGNORE INTO user_roles (user_id, role_id) VALUES (1, 1);
INSERT IGNORE INTO user_sites (user_id, site_id) VALUES (1, 1), (1, 2), (1, 3);
