<%
' ============================================
' 企业多系统连接中枢 - 路由规则编辑
' 文件: route_edit.asp
' ============================================
Response.Charset = "UTF-8"
Session.CodePage = 65001
<!--#include file="inc/conn.asp" -->
CheckLogin()

Dim id, matchType, condition, target, priority, msg
id = Request.QueryString("id")

If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    matchType = Trim(Request.Form("match_type"))
    condition = Trim(Request.Form("condition"))
    target = Trim(Request.Form("target"))
    priority = Trim(Request.Form("priority"))
    
    If condition <> "" And target <> "" Then
        If id <> "" Then
            ExecuteSQL "UPDATE routes SET match_type='" & matchType & "', condition='" & condition & "', target='" & target & "', priority=" & priority & " WHERE id=" & id
        Else
            ExecuteSQL "INSERT INTO routes (match_type, condition, target, priority, created_at) VALUES ('" & matchType & "', '" & condition & "', '" & target & "', " & priority & ", '" & Now() & "')"
        End If
        Response.Redirect "index.asp?page=routes&msg=saved"
    Else
        msg = "请填写匹配条件和目标服务"
    End If
End If

If id <> "" Then
    Dim rs
    Set rs = GetRecordset("SELECT * FROM routes WHERE id=" & id)
    If Not rs.EOF Then
        matchType = rs("match_type")
        condition = rs("condition")
        target = rs("target")
        priority = rs("priority")
    End If
    rs.Close
End If
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title><%= If id<>"" Then Response.Write "编辑" Else Response.Write "添加" %>路由规则 - 集成中枢</title>
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
                <a href="index.asp?page=mapping" class="nav-item"><span class="icon">&#128260;</span> 数据映射</a>
                <a href="index.asp?page=routes" class="nav-item active"><span class="icon">&#128739;</span> 路由配置</a>
                <a href="index.asp?page=monitor" class="nav-item"><span class="icon">&#128200;</span> 监控中心</a>
                <a href="index.asp?page=logs" class="nav-item"><span class="icon">&#128221;</span> 日志审计</a>
                <a href="index.asp?page=settings" class="nav-item"><span class="icon">&#9881;</span> 系统设置</a>
                <a href="sync.asp" class="nav-item"><span class="icon">&#128256;</span> 数据同步</a>
                <a href="queue_manage.asp" class="nav-item"><span class="icon">&#128230;</span> 队列管理</a>
                <a href="test_api.asp" class="nav-item"><span class="icon">&#128300;</span> API 测试</a>
            </ul>
        </div>
        <div class="main-content">
            <div class="header">
                <h3><%= If id<>"" Then Response.Write "编辑路由规则" Else Response.Write "添加路由规则" %></h3>
                <div class="header-right"><span>管理员: <%= GetUserName() %></span><a href="logout.asp" class="btn btn-danger">退出</a></div>
            </div>
            <div class="page-content">
                <div class="card">
                    <% If msg <> "" Then %><div class="alert alert-error"><%= msg %></div><% End If %>
                    <form method="post" action="">
                        <div class="form-group"><label>匹配类型</label>
                            <select name="match_type">
                                <option value="prefix"<% If matchType="prefix" Then Response.Write " selected" %>>前缀匹配</option>
                                <option value="exact"<% If matchType="exact" Then Response.Write " selected" %>>精确匹配</option>
                                <option value="header"<% If matchType="header" Then Response.Write " selected" %>>Header 匹配</option>
                            </select>
                        </div>
                        <div class="form-group"><label>匹配条件 *</label><input type="text" name="condition" value="<%= EscapeHtml(condition) %>" placeholder="/api/v1 或 X-Tenant: A" required></div>
                        <div class="form-group"><label>目标服务 *</label><input type="text" name="target" value="<%= EscapeHtml(target) %>" placeholder="service-name" required></div>
                        <div class="form-group"><label>优先级</label><input type="number" name="priority" value="<%= If priority="" Then Response.Write "100" Else Response.Write priority %>"></div>
                        <button type="submit" class="btn btn-primary">保存</button>
                        <a href="index.asp?page=routes" class="btn">返回</a>
                    </form>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
<% CloseConn() %>