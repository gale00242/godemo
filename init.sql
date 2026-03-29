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

-- 菜单表
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
(1, 'admin', '$2a$12$ESF0L2ZF1RD75T3nb2AZXuxO0L4Jb1VVYdqkN4AXur1ipF1IvIAam', 'admin@example.com', '13800138000', 1),
(2, 'operator1', '$2a$12$ESF0L2ZF1RD75T3nb2AZXuxO0L4Jb1VVYdqkN4AXur1ipF1IvIAam', 'op1@example.com', '13800138001', 1),
(3, 'zhangsan', '$2a$12$ESF0L2ZF1RD75T3nb2AZXuxO0L4Jb1VVYdqkN4AXur1ipF1IvIAam', 'zhangsan@example.com', '13800138002', 1),
(4, 'lisi', '$2a$12$ESF0L2ZF1RD75T3nb2AZXuxO0L4Jb1VVYdqkN4AXur1ipF1IvIAam', 'lisi@example.com', '13800138003', 1),
(5, 'wangwu', '$2a$12$ESF0L2ZF1RD75T3nb2AZXuxO0L4Jb1VVYdqkN4AXur1ipF1IvIAam', 'wangwu@example.com', '13800138004', 1),
(6, 'zhaoliu', '$2a$12$ESF0L2ZF1RD75T3nb2AZXuxO0L4Jb1VVYdqkN4AXur1ipF1IvIAam', 'zhaoliu@example.com', '13800138005', 1),
(7, 'sunqi', '$2a$12$ESF0L2ZF1RD75T3nb2AZXuxO0L4Jb1VVYdqkN4AXur1ipF1IvIAam', 'sunqi@example.com', '13800138006', 1),
(8, 'zhouba', '$2a$12$ESF0L2ZF1RD75T3nb2AZXuxO0L4Jb1VVYdqkN4AXur1ipF1IvIAam', 'zhouba@example.com', '13800138007', 1),
(9, 'wujiu', '$2a$12$ESF0L2ZF1RD75T3nb2AZXuxO0L4Jb1VVYdqkN4AXur1ipF1IvIAam', 'wujiu@example.com', '13800138008', 1),
(10, 'zhengshi', '$2a$12$ESF0L2ZF1RD75T3nb2AZXuxO0L4Jb1VVYdqkN4AXur1ipF1IvIAam', 'zhengshi@example.com', '13800138009', 1),
(11, 'chenyiy', '$2a$12$ESF0L2ZF1RD75T3nb2AZXuxO0L4Jb1VVYdqkN4AXur1ipF1IvIAam', 'chenyiy@example.com', '13800138010', 1),
(12, 'demo01', '$2a$12$ESF0L2ZF1RD75T3nb2AZXuxO0L4Jb1VVYdqkN4AXur1ipF1IvIAam', 'demo01@example.com', '13800138011', 1),
(13, 'demo02', '$2a$12$ESF0L2ZF1RD75T3nb2AZXuxO0L4Jb1VVYdqkN4AXur1ipF1IvIAam', 'demo02@example.com', '13800138012', 1);

-- 角色表
INSERT IGNORE INTO roles (id, name, code, description) VALUES 
(1, '超级管理员', 'super_admin', '拥有所有权限'),
(2, '站点管理员', 'site_admin', '管理单个站点'),
(3, '运营人员', 'operator', '普通运营权限');

-- 菜单表 (带二级菜单)
INSERT IGNORE INTO menus (id, name, path, icon, parent_id, sort, is_active) VALUES 
(1, '首页', '/home', 'HomeFilled', 0, 1, 1),
(100, '系统设置', '/settings', 'Setting', 0, 100, 1),
(101, '用户管理', '/users', 'User', 100, 101, 1),
(102, '角色管理', '/roles', 'Key', 100, 102, 1),
(103, '站点管理', '/sites', 'OfficeBuilding', 100, 103, 1);

-- 给超级管理员分配所有菜单
INSERT IGNORE INTO role_menus (role_id, menu_id) 
SELECT 1, id FROM menus;

-- 给运营人员分配首页和系统设置下的子菜单
INSERT IGNORE INTO role_menus (role_id, menu_id) VALUES 
(3, 1),  -- 首页
(3, 100), -- 系统设置
(3, 101); -- 用户管理

-- 给用户分配角色
INSERT IGNORE INTO user_roles (user_id, role_id) VALUES 
(1, 1),  -- admin 是超级管理员
(2, 3);  -- operator1 是运营人员

-- 给用户分配站点
INSERT IGNORE INTO user_sites (user_id, site_id) VALUES 
(1, 1), (1, 2), (1, 3),  -- admin 可以访问所有站点
(2, 1), (2, 2);          -- operator1 可以访问站点A和B
