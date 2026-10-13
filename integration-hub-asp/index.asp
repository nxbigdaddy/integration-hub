<%
' ============================================
' 企业多系统连接中枢 - 主控制台
' 文件: index.asp
' ============================================
Response.Charset = "UTF-8"
Session.CodePage = 65001

' 引入公共函数
<!--#include file="inc/conn.asp" -->

' 检查登录
CheckLogin()

' 获取当前页面
Dim currentPage
currentPage = Request.QueryString("page")
If currentPage = "" Then currentPage = "dashboard"
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>控制台 - 企业多系统连接中枢</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="layout">
        <!-- 侧边栏 -->
        <div class="sidebar">
            <div class="sidebar-logo">
                <h2>集成中枢</h2>
                <span>Integration Hub</span>
            </div>
            <ul class="nav-menu">
                <a href="index.asp?page=dashboard" class="nav-item<% If currentPage="dashboard" Then Response.Write " active" %>"><span class="icon">&#128202;</span> 首页概览</a>
                <a href="index.asp?page=systems" class="nav-item<% If currentPage="systems" Then Response.Write " active" %>"><span class="icon">&#128268;</span> 系统管理</a>
                <a href="index.asp?page=apis" class="nav-item<% If currentPage="apis" Then Response.Write " active" %>"><span class="icon">&#128279;</span> API 管理</a>
                <a href="index.asp?page=mapping" class="nav-item<% If currentPage="mapping" Then Response.Write " active" %>"><span class="icon">&#128260;</span> 数据映射</a>
                <a href="index.asp?page=routes" class="nav-item<% If currentPage="routes" Then Response.Write " active" %>"><span class="icon">&#128739;</span> 路由配置</a>
                <a href="index.asp?page=monitor" class="nav-item<% If currentPage="monitor" Then Response.Write " active" %>"><span class="icon">&#128200;</span> 监控中心</a>
                <a href="index.asp?page=logs" class="nav-item<% If currentPage="logs" Then Response.Write " active" %>"><span class="icon">&#128221;</span> 日志审计</a>
                <a href="index.asp?page=settings" class="nav-item<% If currentPage="settings" Then Response.Write " active" %>"><span class="icon">&#9881;</span> 系统设置</a>
                <a href="sync.asp" class="nav-item"><span class="icon">&#128256;</span> 数据同步</a>
                <a href="queue_manage.asp" class="nav-item"><span class="icon">&#128230;</span> 队列管理</a>
                <a href="test_api.asp" class="nav-item"><span class="icon">&#128300;</span> API 测试</a>
            </ul>
        </div>
        
        <!-- 主内容区 -->
        <div class="main-content">
            <div class="header">
                <h3><%= GetPageTitle(currentPage) %></h3>
                <div class="header-right">
                    <span>管理员: <%= GetUserName() %></span>
                    <a href="logout.asp" class="btn btn-danger">退出</a>
                </div>
            </div>
            
            <div class="page-content">
<%
Select Case currentPage
    Case "dashboard"
%>
                <!-- 首页概览 -->
                <div class="stats-grid">
                    <div class="stat-card"><div class="label">已接入系统</div><div class="value">5</div><div class="trend up">&#8593; 2 本月新增</div></div>
                    <div class="stat-card"><div class="label">活跃 API</div><div class="value">128</div><div class="trend up">&#8593; 12 本周新增</div></div>
                    <div class="stat-card"><div class="label">今日调用量</div><div class="value">45.2K</div><div class="trend up">&#8593; 8.5% 较昨日</div></div>
                    <div class="stat-card"><div class="label">平均延迟</div><div class="value">45ms</div><div class="trend down">&#8595; 12ms 较昨日</div></div>
                </div>
                <div class="card">
                    <h3>系统拓扑</h3>
                    <div class="topology">
                        <div class="node hub">集成中枢</div>
                        <div class="node sys1">ERP</div>
                        <div class="node sys2">CRM</div>
                        <div class="node sys3">HRM</div>
                        <div class="node sys4">OA</div>
                        <div class="node sys5">WMS</div>
                    </div>
                </div>
                <div class="card">
                    <h3>最近告警</h3>
                    <table>
                        <thead><tr><th>时间</th><th>级别</th><th>内容</th><th>状态</th></tr></thead>
                        <tbody>
                            <tr><td>2026-04-10 14:32</td><td><span class="status inactive">警告</span></td><td>CRM 系统响应延迟 > 200ms</td><td>已恢复</td></tr>
                            <tr><td>2026-04-10 12:15</td><td><span class="status inactive">错误</span></td><td>数据转换失败: 字段类型不匹配</td><td>已处理</td></tr>
                        </tbody>
                    </table>
                </div>
<%
    Case "systems"
%>
                <!-- 系统管理 -->
                <div class="card">
                    <div class="toolbar">
                        <h3>已接入系统</h3>
                        <a href="system_edit.asp" class="btn btn-primary">+ 新增系统</a>
                    </div>
                    <table>
                        <thead><tr><th>系统名称</th><th>类型</th><th>协议</th><th>状态</th><th>接入时间</th><th>操作</th></tr></thead>
                        <tbody>
                            <tr><td>SAP ERP</td><td>ERP</td><td>REST</td><td><span class="status active">运行中</span></td><td>2026-03-01</td><td><a href="system_edit.asp?id=1" class="btn btn-primary">编辑</a> <a href="system_action.asp?id=1&action=disable" class="btn btn-danger">禁用</a></td></tr>
                            <tr><td>Salesforce</td><td>CRM</td><td>REST</td><td><span class="status active">运行中</span></td><td>2026-03-15</td><td><a href="system_edit.asp?id=2" class="btn btn-primary">编辑</a> <a href="system_action.asp?id=2&action=disable" class="btn btn-danger">禁用</a></td></tr>
                            <tr><td>Workday</td><td>HRM</td><td>SOAP</td><td><span class="status active">运行中</span></td><td>2026-04-01</td><td><a href="system_edit.asp?id=3" class="btn btn-primary">编辑</a> <a href="system_action.asp?id=3&action=disable" class="btn btn-danger">禁用</a></td></tr>
                            <tr><td>钉钉 OA</td><td>OA</td><td>Webhook</td><td><span class="status inactive">已禁用</span></td><td>2026-04-05</td><td><a href="system_edit.asp?id=4" class="btn btn-primary">编辑</a> <a href="system_action.asp?id=4&action=enable" class="btn btn-success">启用</a></td></tr>
                            <tr><td>富勒 WMS</td><td>WMS</td><td>AMQP</td><td><span class="status active">运行中</span></td><td>2026-04-08</td><td><a href="system_edit.asp?id=5" class="btn btn-primary">编辑</a> <a href="system_action.asp?id=5&action=disable" class="btn btn-danger">禁用</a></td></tr>
                        </tbody>
                    </table>
                </div>
<%
    Case "apis"
%>
                <!-- API 管理 -->
                <div class="card">
                    <div class="toolbar">
                        <h3>API 列表</h3>
                        <a href="api_edit.asp" class="btn btn-primary">+ 注册 API</a>
                    </div>
                    <table>
                        <thead><tr><th>API 路径</th><th>方法</th><th>所属系统</th><th>版本</th><th>调用次数</th><th>状态</th><th>操作</th></tr></thead>
                        <tbody>
                            <tr><td>/api/v1/orders</td><td>POST</td><td>SAP ERP</td><td>v1.0</td><td>12,456</td><td><span class="status active">正常</span></td><td><a href="api_edit.asp?id=1" class="btn btn-primary">编辑</a></td></tr>
                            <tr><td>/api/v1/customers</td><td>GET</td><td>Salesforce</td><td>v2.1</td><td>8,923</td><td><span class="status active">正常</span></td><td><a href="api_edit.asp?id=2" class="btn btn-primary">编辑</a></td></tr>
                            <tr><td>/api/v1/employees</td><td>GET</td><td>Workday</td><td>v1.0</td><td>5,678</td><td><span class="status active">正常</span></td><td><a href="api_edit.asp?id=3" class="btn btn-primary">编辑</a></td></tr>
                            <tr><td>/api/v1/inventory</td><td>PUT</td><td>富勒 WMS</td><td>v1.2</td><td>3,245</td><td><span class="status active">正常</span></td><td><a href="api_edit.asp?id=4" class="btn btn-primary">编辑</a></td></tr>
                        </tbody>
                    </table>
                </div>
<%
    Case "mapping"
%>
                <!-- 数据映射 -->
                <div class="card">
                    <div class="toolbar">
                        <h3>数据映射规则</h3>
                        <a href="mapping_edit.asp" class="btn btn-primary">+ 创建映射</a>
                    </div>
                    <table>
                        <thead><tr><th>映射名称</th><th>源系统</th><th>目标系统</th><th>字段数</th><th>状态</th><th>操作</th></tr></thead>
                        <tbody>
                            <tr><td>ERP&#8594;CRM 客户同步</td><td>SAP ERP</td><td>Salesforce</td><td>15</td><td><span class="status active">启用</span></td><td><a href="mapping_edit.asp?id=1" class="btn btn-primary">编辑</a> <a href="mapping_action.asp?id=1&action=disable" class="btn btn-danger">禁用</a></td></tr>
                            <tr><td>HRM&#8594;OA 员工同步</td><td>Workday</td><td>钉钉 OA</td><td>8</td><td><span class="status active">启用</span></td><td><a href="mapping_edit.asp?id=2" class="btn btn-primary">编辑</a> <a href="mapping_action.asp?id=2&action=disable" class="btn btn-danger">禁用</a></td></tr>
                            <tr><td>ERP&#8594;WMS 库存同步</td><td>SAP ERP</td><td>富勒 WMS</td><td>12</td><td><span class="status inactive">禁用</span></td><td><a href="mapping_edit.asp?id=3" class="btn btn-primary">编辑</a> <a href="mapping_action.asp?id=3&action=enable" class="btn btn-success">启用</a></td></tr>
                        </tbody>
                    </table>
                </div>
<%
    Case "routes"
%>
                <!-- 路由配置 -->
                <div class="card">
                    <div class="toolbar">
                        <h3>路由规则</h3>
                        <a href="route_edit.asp" class="btn btn-primary">+ 添加规则</a>
                    </div>
                    <table>
                        <thead><tr><th>规则 ID</th><th>匹配类型</th><th>匹配条件</th><th>目标服务</th><th>优先级</th><th>操作</th></tr></thead>
                        <tbody>
                            <tr><td>r-001</td><td>前缀匹配</td><td>/api/v1/orders</td><td>order-service</td><td>100</td><td><a href="route_edit.asp?id=1" class="btn btn-primary">编辑</a></td></tr>
                            <tr><td>r-002</td><td>Header 匹配</td><td>X-Tenant: A</td><td>tenant-a-service</td><td>200</td><td><a href="route_edit.asp?id=2" class="btn btn-primary">编辑</a></td></tr>
                            <tr><td>r-003</td><td>精确匹配</td><td>/health</td><td>health-check</td><td>300</td><td><a href="route_edit.asp?id=3" class="btn btn-primary">编辑</a></td></tr>
                        </tbody>
                    </table>
                </div>
<%
    Case "monitor"
%>
                <!-- 监控中心 -->
                <div class="stats-grid">
                    <div class="stat-card"><div class="label">QPS (当前)</div><div class="value">1,234</div></div>
                    <div class="stat-card"><div class="label">P99 延迟</div><div class="value">89ms</div></div>
                    <div class="stat-card"><div class="label">错误率</div><div class="value">0.02%</div></div>
                    <div class="stat-card"><div class="label">活跃连接</div><div class="value">567</div></div>
                </div>
                <div class="card">
                    <h3>调用量趋势 (24h)</h3>
                    <div class="chart-placeholder">&#128200; 调用量趋势图表 (集成 ECharts/Grafana)</div>
                </div>
                <div class="card">
                    <h3>系统健康状态</h3>
                    <table>
                        <thead><tr><th>系统</th><th>状态</th><th>CPU</th><th>内存</th><th>延迟</th><th>最后检查</th></tr></thead>
                        <tbody>
                            <tr><td>SAP ERP</td><td><span class="status active">健康</span></td><td>45%</td><td>62%</td><td>35ms</td><td>10s 前</td></tr>
                            <tr><td>Salesforce</td><td><span class="status active">健康</span></td><td>32%</td><td>58%</td><td>42ms</td><td>10s 前</td></tr>
                            <tr><td>Workday</td><td><span class="status active">健康</span></td><td>28%</td><td>45%</td><td>56ms</td><td>10s 前</td></tr>
                            <tr><td>富勒 WMS</td><td><span class="status inactive">警告</span></td><td>78%</td><td>82%</td><td>180ms</td><td>10s 前</td></tr>
                        </tbody>
                    </table>
                </div>
<%
    Case "logs"
%>
                <!-- 日志审计 -->
                <div class="card">
                    <h3>操作日志</h3>
                    <div style="margin-bottom:15px">
                        <form method="get" action="index.asp" style="display:inline">
                            <input type="hidden" name="page" value="logs">
                            <input type="text" name="keyword" class="search-box" placeholder="搜索日志..." value="<%= Request.QueryString("keyword") %>">
                            <button type="submit" class="btn btn-primary">搜索</button>
                        </form>
                    </div>
                    <div id="logContainer">
                        <div class="log-item"><span class="log-time">2026-04-10 14:32:15</span><span class="log-level info">INFO</span><span>用户 admin 创建数据映射规则: ERP&#8594;CRM 客户同步</span></div>
                        <div class="log-item"><span class="log-time">2026-04-10 14:28:03</span><span class="log-level warn">WARN</span><span>系统 CRM 响应延迟超过阈值 (210ms > 200ms)</span></div>
                        <div class="log-item"><span class="log-time">2026-04-10 14:15:42</span><span class="log-level error">ERROR</span><span>数据转换失败: 字段 amount 类型不匹配 (期望 Number, 收到 String)</span></div>
                        <div class="log-item"><span class="log-time">2026-04-10 13:58:20</span><span class="log-level info">INFO</span><span>系统 WMS 成功接入，协议: AMQP</span></div>
                        <div class="log-item"><span class="log-time">2026-04-10 13:45:11</span><span class="log-level info">INFO</span><span>用户 admin 更新路由规则 r-002</span></div>
                        <div class="log-item"><span class="log-time">2026-04-10 13:30:05</span><span class="log-level info">INFO</span><span>系统启动完成，加载 5 个连接器</span></div>
                    </div>
                </div>
<%
    Case "settings"
%>
                <!-- 系统设置 -->
                <div class="card">
                    <h3>基础配置</h3>
                    <div class="config-item"><span class="config-key">系统名称</span><span class="config-value">企业多系统连接中枢</span></div>
                    <div class="config-item"><span class="config-key">运行环境</span><span class="config-value">Production</span></div>
                    <div class="config-item"><span class="config-key">数据库类型</span><span class="config-value">SQL Server 2019</span></div>
                    <div class="config-item"><span class="config-key">服务器</span><span class="config-value">IIS 10.0 / Windows Server 2019</span></div>
                </div>
                <div class="card">
                    <h3>安全配置</h3>
                    <form method="post" action="settings_save.asp">
                        <div class="form-group"><label>Session 超时时间 (分钟)</label><input type="number" name="session_timeout" value="30"></div>
                        <div class="form-group"><label>最大登录失败次数</label><input type="number" name="max_login_fail" value="5"></div>
                        <div class="form-group"><label>IP 白名单 (每行一个)</label><textarea name="ip_whitelist">203.0.113.10/8&#10;203.0.113.10/12&#10;203.0.113.10/16</textarea></div>
                        <button type="submit" class="btn btn-primary">保存配置</button>
                    </form>
                </div>
<%
    Case Else
%>
                <div class="card"><h3>页面不存在</h3><p>请求的页面不存在，请返回<a href="index.asp">首页</a>。</p></div>
<%
End Select
%>
            </div>
        </div>
    </div>
</body>
</html>
<%
Function GetPageTitle(page)
    Select Case page
        Case "dashboard": GetPageTitle = "首页概览"
        Case "systems": GetPageTitle = "系统管理"
        Case "apis": GetPageTitle = "API 管理"
        Case "mapping": GetPageTitle = "数据映射"
        Case "routes": GetPageTitle = "路由配置"
        Case "monitor": GetPageTitle = "监控中心"
        Case "logs": GetPageTitle = "日志审计"
        Case "settings": GetPageTitle = "系统设置"
        Case Else: GetPageTitle = "控制台"
    End Select
End Function

CloseConn()
%>