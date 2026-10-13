<%
' ============================================
' 企业多系统连接中枢 - API 编辑
' 文件: api_edit.asp
' ============================================
Response.Charset = "UTF-8"
Session.CodePage = 65001
<!--#include file="inc/conn.asp" -->
CheckLogin()

Dim id, path, method, systemId, version, msg
id = Request.QueryString("id")

If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    path = Trim(Request.Form("path"))
    method = Trim(Request.Form("method"))
    systemId = Trim(Request.Form("system_id"))
    version = Trim(Request.Form("version"))
    
    If path <> "" Then
        If id <> "" Then
            ExecuteSQL "UPDATE apis SET path='" & path & "', method='" & method & "', system_id=" & systemId & ", version='" & version & "' WHERE id=" & id
        Else
            ExecuteSQL "INSERT INTO apis (path, method, system_id, version, created_at) VALUES ('" & path & "', '" & method & "', " & systemId & ", '" & version & "', '" & Now() & "')"
        End If
        Response.Redirect "index.asp?page=apis&msg=saved"
    Else
        msg = "请填写 API 路径"
    End If
End If

If id <> "" Then
    Dim rs
    Set rs = GetRecordset("SELECT * FROM apis WHERE id=" & id)
    If Not rs.EOF Then
        path = rs("path")
        method = rs("method")
        systemId = rs("system_id")
        version = rs("version")
    End If
    rs.Close
End If
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title><%= If id<>"" Then Response.Write "编辑" Else Response.Write "注册" %>API - 集成中枢</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="layout">
        <div class="sidebar">
            <div class="sidebar-logo"><h2>集成中枢</h2><span>Integration Hub</span></div>
            <ul class="nav-menu">
                <a href="index.asp?page=dashboard" class="nav-item"><span class="icon">&#128202;</span> 首页概览</a>
                <a href="index.asp?page=systems" class="nav-item"><span class="icon">&#128268;</span> 系统管理</a>
                <a href="index.asp?page=apis" class="nav-item active"><span class="icon">&#128279;</span> API 管理</a>
                <a href="index.asp?page=mapping" class="nav-item"><span class="icon">&#128260;</span> 数据映射</a>
                <a href="index.asp?page=routes" class="nav-item"><span class="icon">&#128739;</span> 路由配置</a>
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
                <h3><%= If id<>"" Then Response.Write "编辑 API" Else Response.Write "注册 API" %></h3>
                <div class="header-right"><span>管理员: <%= GetUserName() %></span><a href="logout.asp" class="btn btn-danger">退出</a></div>
            </div>
            <div class="page-content">
                <div class="card">
                    <% If msg <> "" Then %><div class="alert alert-error"><%= msg %></div><% End If %>
                    <form method="post" action="">
                        <div class="form-group"><label>API 路径 *</label><input type="text" name="path" value="<%= EscapeHtml(path) %>" placeholder="/api/v1/..." required></div>
                        <div class="form-group"><label>请求方法</label>
                            <select name="method">
                                <option value="GET"<% If method="GET" Then Response.Write " selected" %>>GET</option>
                                <option value="POST"<% If method="POST" Then Response.Write " selected" %>>POST</option>
                                <option value="PUT"<% If method="PUT" Then Response.Write " selected" %>>PUT</option>
                                <option value="DELETE"<% If method="DELETE" Then Response.Write " selected" %>>DELETE</option>
                            </select>
                        </div>
                        <div class="form-group"><label>所属系统</label>
                            <select name="system_id">
                                <option value="1">SAP ERP</option>
                                <option value="2">Salesforce</option>
                                <option value="3">Workday</option>
                                <option value="4">钉钉 OA</option>
                                <option value="5">富勒 WMS</option>
                            </select>
                        </div>
                        <div class="form-group"><label>版本</label><input type="text" name="version" value="<%= EscapeHtml(version) %>" placeholder="v1.0"></div>
                        <button type="submit" class="btn btn-primary">保存</button>
                        <a href="index.asp?page=apis" class="btn">返回</a>
                    </form>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
<% CloseConn() %>