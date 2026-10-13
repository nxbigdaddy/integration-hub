<%
' ============================================
' 企业多系统连接中枢 - 数据同步执行
' 文件: sync.asp
' 功能: 执行数据同步任务 (从源系统拉取，转换，推送到目标系统)
' ============================================
Response.Charset = "UTF-8"
Session.CodePage = 65001

<!--#include file="inc/conn.asp" -->
<!--#include file="inc/engine.asp" -->
<!--#include file="inc/queue.asp" -->

Dim action, result
action = Request.QueryString("action")

If action = "" Then
    ' 显示同步任务列表
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>数据同步 - 集成中枢</title>
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
                <h3>数据同步任务</h3>
                <div class="header-right"><span>管理员: <%= Session("username") %></span><a href="logout.asp" class="btn btn-danger">退出</a></div>
            </div>
            <div class="page-content">
                <div class="card">
                    <h3>同步任务列表</h3>
                    <table>
                        <thead><tr><th>任务名称</th><th>源系统</th><th>目标系统</th><th>状态</th><th>上次执行</th><th>操作</th></tr></thead>
                        <tbody>
<%
                    Dim rs
                    Set rs = GetRecordset("SELECT * FROM sync_tasks ORDER BY id")
                    Do While Not rs.EOF
%>
                            <tr>
                                <td><%= rs("name") %></td>
                                <td><%= rs("source_system") %></td>
                                <td><%= rs("target_system") %></td>
                                <td><%= GetStatusBadge(rs("status")) %></td>
                                <td><%= FormatDate(rs("last_run")) %></td>
                                <td>
                                    <a href="sync.asp?action=run&id=<%= rs("id") %>" class="btn btn-primary">执行</a>
                                    <a href="sync.asp?action=toggle&id=<%= rs("id") %>" class="btn btn-warning">
                                        <% If rs("status")=1 Then Response.Write "禁用" Else Response.Write "启用" %>
                                    </a>
                                </td>
                            </tr>
<%
                        rs.MoveNext
                    Loop
                    rs.Close
%>
                        </tbody>
                    </table>
                </div>
                <div class="card">
                    <h3>手动触发同步</h3>
                    <form method="get" action="sync.asp">
                        <input type="hidden" name="action" value="run">
                        <div class="form-group"><label>源系统 Endpoint</label><input type="text" name="source_url" placeholder="https://api.example.com/data"></div>
                        <div class="form-group"><label>目标系统 Endpoint</label><input type="text" name="target_url" placeholder="https://api.example.com/ingest"></div>
                        <div class="form-group"><label>映射规则 (source|target|transform;...)</label><textarea name="rules" placeholder="$.id|$.user_id|UPPER;$.name|$.full_name"></textarea></div>
                        <div class="form-group"><label>校验规则 (field|type|param;...)</label><textarea name="validation" placeholder="$.email|EMAIL|;$.phone|PHONE|"></textarea></div>
                        <button type="submit" class="btn btn-primary">执行同步</button>
                    </form>
                </div>
                <div id="result" class="card" style="display:none">
                    <h3>执行结果</h3>
                    <pre id="resultContent" style="white-space:pre-wrap;background:#f5f5f5;padding:15px;border-radius:4px;"></pre>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
<%
ElseIf action = "run" Then
    ' 执行同步任务
    Dim taskId, sourceUrl, targetUrl, rules, validation
    taskId = Request.QueryString("id")
    sourceUrl = Request.QueryString("source_url")
    targetUrl = Request.QueryString("target_url")
    rules = Request.QueryString("rules")
    validation = Request.QueryString("validation")
    
    Dim logMsg, success
    success = True
    
    ' 记录开始
    Dim logger
    Set logger = New Logger
    logger.Info "开始执行数据同步任务", Session("username")
    
    ' 1. 从源系统拉取数据 (模拟)
    Dim httpClient, sourceData
    Set httpClient = New HttpClient
    
    If sourceUrl <> "" Then
        sourceData = httpClient.Get(sourceUrl, 5000)
        If GetStatus <> 200 Then
            logMsg = "拉取源数据失败: " & GetError
            logger.ErrorLog logMsg, Session("username")
            success = False
        End If
    Else
        ' 模拟数据
        sourceData = "{""id"": ""1001"", ""name"": ""Test User"", ""email"": ""test@example.com"", ""phone"": ""13800138000""}"
    End If
    
    If success And sourceData <> "" Then
        ' 2. 数据校验
        If validation <> "" Then
            Dim validator
            Set validator = New ValidationEngine
            If Not validator.Validate(sourceData, validation) Then
                logMsg = "数据校验失败，终止同步"
                logger.Warn logMsg, Session("username")
                success = False
            End If
            Set validator = Nothing
        End If
    End If
    
    If success And sourceData <> "" Then
        ' 3. 数据转换
        Dim transformer, transformedData
        Set transformer = New DataTransformer
        transformedData = transformer.Transform(sourceData, rules)
        Set transformer = Nothing
        
        ' 4. 推送到目标系统
        If targetUrl <> "" Then
            Dim postResult
            postResult = httpClient.Post(targetUrl, transformedData, 5000)
            If PostStatus <> 200 Then
                logMsg = "推送目标系统失败: " & PostError
                logger.ErrorLog logMsg, Session("username")
                success = False
            Else
                logMsg = "同步成功，推送数据: " & transformedData
                logger.Info logMsg, Session("username")
            End If
        Else
            logMsg = "同步成功 (模拟)，转换结果: " & transformedData
            logger.Info logMsg, Session("username")
        End If
    End If
    
    ' 更新任务状态
    If taskId <> "" Then
        conn.Execute "UPDATE sync_tasks SET last_run='" & Now() & "', last_status=" & IIf(success, 1, 0) & " WHERE id=" & taskId
    End If
    
    Set httpClient = Nothing
    Set logger = Nothing
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>同步结果 - 集成中枢</title>
    <link rel="stylesheet" href="css/style.css">
    <meta http-equiv="refresh" content="3;url=sync.asp">
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
                <h3>同步执行结果</h3>
                <div class="header-right"><span>管理员: <%= Session("username") %></span><a href="logout.asp" class="btn btn-danger">退出</a></div>
            </div>
            <div class="page-content">
                <div class="card">
                    <div class="alert <%= IIf(success, "alert-success", "alert-error") %>">
                        <%= IIf(success, "同步成功", "同步失败") %>
                    </div>
                    <pre style="white-space:pre-wrap;background:#f5f5f5;padding:15px;border-radius:4px;"><%= logMsg %></pre>
                    <p style="margin-top:15px">3 秒后自动返回任务列表... <a href="sync.asp">立即返回</a></p>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
<%
ElseIf action = "toggle" Then
    Dim toggleId
    toggleId = Request.QueryString("id")
    conn.Execute "UPDATE sync_tasks SET status=1-status WHERE id=" & toggleId
    Response.Redirect "sync.asp"
End If

CloseConn()

Function IIf(cond, trueVal, falseVal)
    If cond Then IIf = trueVal Else IIf = falseVal
End Function
%>