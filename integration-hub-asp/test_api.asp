<%
' ============================================
' 企业多系统连接中枢 - API 测试页面
' 文件: test_api.asp
' 功能: 测试路由、转换、校验 API
' ============================================
Response.Charset = "UTF-8"
Session.CodePage = 65001

<!--#include file="inc/conn.asp" -->
<!--#include file="inc/engine.asp" -->

CheckLogin()

Dim testResult
testResult = ""

If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    Dim testType, testData
    testType = Request.Form("test_type")
    testData = Request.Form("test_data")
    
    Select Case testType
        Case "route"
            Dim engine, headers
            Set engine = New RouteEngine
            engine.LoadRules
            Set headers = Server.CreateObject("Scripting.Dictionary")
            headers.Add "X-Tenant", "A"
            Dim target
            target = engine.Resolve(testData, headers)
            testResult = "路由匹配结果: " & IIf(target <> "", target, "未找到匹配路由")
            Set engine = Nothing
            Set headers = Nothing
            
        Case "transform"
            Dim transformer
            Set transformer = New DataTransformer
            ' 默认规则
            Dim rules
            rules = "$.id|$.user_id|UPPER;$.name|$.full_name;$.email|$.contact|LOWER"
            Dim result
            result = transformer.Transform(testData, rules)
            testResult = "转换结果: " & result
            Set transformer = Nothing
            
        Case "validate"
            Dim validator
            Set validator = New ValidationEngine
            ' 默认规则
            Dim vRules
            vRules = "$.email|EMAIL|;$.phone|PHONE|;$.name|REQUIRED|"
            Dim isValid
            isValid = validator.Validate(testData, vRules)
            testResult = "校验结果: " & IIf(isValid, "通过", "失败")
            Set validator = Nothing
    End Select
End If
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>API 测试 - 集成中枢</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="layout">
        <div class="sidebar">
            <div class="sidebar-logo"><h2>集成中枢</h2><span>Integration Hub</span></div>
            <ul class="nav-menu">
                <a href="index.asp?page=dashboard" class="nav-item"><span class="icon">&#128202;</span> 首页概览</a>
                <a href="index.asp?page=systems" class="nav-item"><span class="icon">&#128268;</span> 系统管理</a>
                <a href="index.asp?page=apis" class="nav-item"><span class="icon">&#128279;</span> API 管理</a>
                <a href="index.asp?page=mapping" class="nav-item active"><span class="icon">&#128260;</span> 数据映射</a>
                <a href="index.asp?page=routes" class="nav-item"><span class="icon">&#128739;</span> 路由配置</a>
                <a href="index.asp?page=monitor" class="nav-item"><span class="icon">&#128200;</span> 监控中心</a>
                <a href="index.asp?page=logs" class="nav-item"><span class="icon">&#128221;</span> 日志审计</a>
                <a href="index.asp?page=settings" class="nav-item"><span class="icon">&#9881;</span> 系统设置</a>
            </ul>
        </div>
        <div class="main-content">
            <div class="header">
                <h3>API 测试</h3>
                <div class="header-right"><span>管理员: <%= GetUserName() %></span><a href="logout.asp" class="btn btn-danger">退出</a></div>
            </div>
            <div class="page-content">
                <div class="card">
                    <h3>路由引擎测试</h3>
                    <form method="post" action="">
                        <input type="hidden" name="test_type" value="route">
                        <div class="form-group"><label>请求路径</label><input type="text" name="test_data" value="/api/v1/orders" placeholder="/api/v1/orders"></div>
                        <button type="submit" class="btn btn-primary">测试路由</button>
                    </form>
                </div>
                <div class="card">
                    <h3>数据转换测试</h3>
                    <form method="post" action="">
                        <input type="hidden" name="test_type" value="transform">
                        <div class="form-group"><label>源数据 (JSON)</label><textarea name="test_data" placeholder='{"id": "abc123", "name": "test user", "email": "TEST@EXAMPLE.COM"}'>{"id": "abc123", "name": "test user", "email": "TEST@EXAMPLE.COM"}</textarea></div>
                        <button type="submit" class="btn btn-primary">测试转换</button>
                    </form>
                </div>
                <div class="card">
                    <h3>数据校验测试</h3>
                    <form method="post" action="">
                        <input type="hidden" name="test_type" value="validate">
                        <div class="form-group"><label>待校验数据 (JSON)</label><textarea name="test_data" placeholder='{"email": "test@example.com", "phone": "13800138000", "name": "test"}'>{"email": "test@example.com", "phone": "13800138000", "name": "test"}</textarea></div>
                        <button type="submit" class="btn btn-primary">测试校验</button>
                    </form>
                </div>
                <% If testResult <> "" Then %>
                <div class="card">
                    <h3>测试结果</h3>
                    <div class="alert alert-success"><%= testResult %></div>
                </div>
                <% End If %>
            </div>
        </div>
    </div>
</body>
</html>
<%
CloseConn()

Function IIf(cond, trueVal, falseVal)
    If cond Then IIf = trueVal Else IIf = falseVal
End Function
%>