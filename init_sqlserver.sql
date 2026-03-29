-- SQL Server 初始化脚本

-- 如果数据库存在则删除并重新创建
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'go_vue_admin')
BEGIN
    DROP DATABASE go_vue_admin;
END
GO

CREATE DATABASE go_vue_admin;
GO

USE go_vue_admin;
GO

-- 站点表
CREATE TABLE sites (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(128) NOT NULL,
    code NVARCHAR(64) NOT NULL UNIQUE,
    domain NVARCHAR(256) NULL,
    is_active BIT DEFAULT 1
);
GO

-- 用户表
CREATE TABLE users (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    username NVARCHAR(64) NOT NULL UNIQUE,
    password NVARCHAR(256) NOT NULL,
    email NVARCHAR(128) NULL,
    phone NVARCHAR(32) NULL,
    is_active BIT DEFAULT 1
);
GO

-- 角色表
CREATE TABLE roles (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(64) NOT NULL,
    code NVARCHAR(64) NOT NULL UNIQUE,
    description NVARCHAR(256) NULL,
    is_active BIT DEFAULT 1
);
GO

-- 菜单表
CREATE TABLE menus (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(64) NOT NULL,
    path NVARCHAR(128) NULL,
    icon NVARCHAR(64) NULL,
    parent_id BIGINT DEFAULT 0,
    sort BIGINT DEFAULT 0,
    is_active BIT DEFAULT 1
);
GO
CREATE INDEX idx_menus_parent_id ON menus(parent_id);
GO

-- 中间表
CREATE TABLE user_sites (
    user_id BIGINT NOT NULL,
    site_id BIGINT NOT NULL,
    PRIMARY KEY (user_id, site_id)
);
GO

CREATE TABLE user_roles (
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    PRIMARY KEY (user_id, role_id)
);
GO

CREATE TABLE role_menus (
    role_id BIGINT NOT NULL,
    menu_id BIGINT NOT NULL,
    PRIMARY KEY (role_id, menu_id)
);
GO

-- 站点数据
SET IDENTITY_INSERT sites ON;
INSERT INTO sites (id, name, code, domain) VALUES 
(1, N'站点A', N'site-a', N'a.example.com'),
(2, N'站点B', N'site-b', N'b.example.com'),
(3, N'站点C', N'site-c', N'c.example.com');
SET IDENTITY_INSERT sites OFF;
GO

-- 用户表
SET IDENTITY_INSERT users ON;
INSERT INTO users (id, username, password, email, phone, is_active) VALUES 
(1, N'admin', N'$2a$12$ESF0L2ZF1RD75T3nb2AZXuxO0L4Jb1VVYdqkN4AXur1ipF1IvIAam', N'admin@example.com', N'13800138000', 1);
SET IDENTITY_INSERT users OFF;
GO

-- 角色表
SET IDENTITY_INSERT roles ON;
INSERT INTO roles (id, name, code, description, is_active) VALUES 
(1, N'超级管理员', N'super_admin', N'拥有所有权限', 1);
SET IDENTITY_INSERT roles OFF;
GO

-- 菜单表
SET IDENTITY_INSERT menus ON;
INSERT INTO menus (id, name, path, icon, parent_id, sort, is_active) VALUES 
(1, N'menu.home', N'/home', N'HomeFilled', 0, 1, 1),
(100, N'menu.systemSettings', N'/settings', N'Setting', 0, 100, 1),
(101, N'menu.userMgmt', N'/users', N'User', 100, 101, 1),
(102, N'menu.roleMgmt', '/roles', N'Key', 100, 102, 1),
(103, N'menu.siteMgmt', '/sites', N'OfficeBuilding', 100, 103, 1);
SET IDENTITY_INSERT menus OFF;
GO

-- 权限分配
INSERT INTO role_menus (role_id, menu_id) SELECT 1, id FROM menus;
INSERT INTO user_roles (user_id, role_id) VALUES (1, 1);
INSERT INTO user_sites (user_id, site_id) VALUES (1, 1), (1, 2), (1, 3);
GO
