-- ==========================================================
-- RBAC 权限系统初始化脚本 (SQL Server 版)
-- 包含：菜单树定义、角色定义、角色与菜单的权限关联
-- ==========================================================

USE go_vue_admin;
GO

-- 1. 清理旧数据（可选，生产环境请谨慎）
DELETE FROM role_menus;
DELETE FROM user_roles;
DELETE FROM menus;
DELETE FROM roles;
GO

-- 2. 初始化菜单表 (menus)
-- 这里的 Path 字段非常重要，它就是后端中间件 CheckPermission("/users") 匹配的唯一标识
SET IDENTITY_INSERT menus ON;
INSERT INTO menus (id, name, path, icon, parent_id, sort, is_active) VALUES 
(1, N'menu.home', N'/home', N'HomeFilled', 0, 1, 1),

-- 系统设置 (父级菜单，不挂载具体 API 权限或挂载通用的)
(100, N'menu.systemSettings', N'/settings', N'Setting', 0, 10, 1),

-- 功能子菜单 (挂载具体的 Path，后端根据这些 Path 拦截接口)
(101, N'menu.userMgmt', N'/users', N'User', 100, 11, 1),
(102, N'menu.roleMgmt', N'/roles', N'Key', 100, 12, 1),
(103, N'menu.siteMgmt', N'/sites', N'OfficeBuilding', 100, 13, 1);
SET IDENTITY_INSERT menus OFF;
GO

-- 3. 初始化角色表 (roles)
-- 角色即“用户组”，通过 Code 标识
SET IDENTITY_INSERT roles ON;
INSERT INTO roles (id, name, code, description, is_active) VALUES 
(1, N'超级管理员', N'admin', N'系统最高权限，不受权限逻辑限制', 1),
(2, N'系统管理员', N'sys_admin', N'可以管理用户和角色', 1),
(3, N'站点运营', N'operator', N'仅能管理站点信息', 1),
(4, N'访客', N'guest', N'仅能查看首页', 1);
SET IDENTITY_INSERT roles OFF;
GO

-- 4. 角色与菜单的权限关联 (role_menus)
-- 这就是您要求的“给用户组分配权限菜单”

-- (1) 超级管理员：拥有所有菜单权限
INSERT INTO role_menus (role_id, menu_id) 
SELECT 1, id FROM menus;

-- (2) 系统管理员：拥有首页、系统设置、用户管理、角色管理 (但不分配站点管理)
INSERT INTO role_menus (role_id, menu_id) VALUES 
(2, 1),   -- 首页
(2, 100), -- 系统设置
(2, 101), -- 用户管理
(2, 102); -- 角色管理

-- (3) 站点运营：仅拥有首页和站点管理
INSERT INTO role_menus (role_id, menu_id) VALUES 
(3, 1),   -- 首页
(3, 103); -- 站点管理

-- (4) 访客：仅有首页
INSERT INTO role_menus (role_id, menu_id) VALUES 
(4, 1);
GO

-- 5. 初始化管理员用户
-- 如果 user 表中没有 admin，则创建。密码默认为 Password123! (bcrypt加密)
IF NOT EXISTS (SELECT 1 FROM users WHERE username = 'admin')
BEGIN
    SET IDENTITY_INSERT users ON;
    INSERT INTO users (id, username, password, email, is_active) 
    VALUES (1, N'admin', N'$2a$12$ESF0L2ZF1RD75T3nb2AZXuxO0L4Jb1VVYdqkN4AXur1ipF1IvIAam', N'admin@example.com', 1);
    SET IDENTITY_INSERT users OFF;
END
GO

-- 6. 给用户绑定角色
-- 给 admin 用户 (ID:1) 绑定 超级管理员角色 (ID:1)
IF NOT EXISTS (SELECT 1 FROM user_roles WHERE user_id = 1 AND role_id = 1)
BEGIN
    INSERT INTO user_roles (user_id, role_id) VALUES (1, 1);
END
GO

PRINT 'RBAC 权限初始化完成';
GO
