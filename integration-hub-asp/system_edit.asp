<%
' ============================================
' 企业多系统连接中枢 - 系统编辑/新增
' 文件: system_edit.asp
' ============================================
Response.Charset = "UTF-8"
Session.CodePage = 65001
<!--#include file="inc/conn.asp" -->
CheckLogin()

Dim id, name, sysType, protocol, endpoint, status, msg
id = Request.QueryString("id")

If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    name = Trim(Request.Form("name"))
    sysType = Trim(Request.Form("type"))
    protocol = Trim(Request.Form("protocol"))
    endpoint = Trim(Request.Form("endpoint"))
    status = Request.Form("status")
    
    If name <> "" And endpoint <> "" Then
        If id <> "" Then
            ' 更新
            ExecuteSQL "UPDATE systems SET name='" & name & "', type='" & sysType & "', protocol='" & protocol & "', endpoint='" & endpoint & "', status=" & status & " WHERE id=" & id
        Else
            ' 新增
            ExecuteSQL "INSERT INTO systems (name, type, protocol, endpoint, status, created_at) VALUES ('" & name & "', '" & sysType & "', '" & protocol & "', '" & endpoint & "', " & status & ", '" & Now() & "')"
        End If
        Response.Redirect "index.asp?page=systems&msg=saved"
    Else
        msg = "请填写必填字段"
    End If
End If

' 加载现有数据
If id <> "" Then
    Dim rs
    Set rs = GetRecordset("SELECT * FROM systems WHERE id=" & id)
    If Not rs.EOF Then
        name = rs("name")
        sysType = rs("type")
        protocol = rs("protocol")
        endpoint = rs("endpoint")
        status = rs("status")
    End If
    rs.Close
End If
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title><%= If id<>"" Then Response.Write "编辑" Else Response.Write "新增" %>系统 - 集成中枢</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="layout">
        <div class="sidebar">
            <div class="sidebar-logo"><h2>集成中枢</h2><span>Integration Hub</span></div>
            <ul class="nav-menu">
                <a href="index.asp?page=dashboard" class="nav-item"><span class="icon">&#128202;</span> 首页概览</a>
                <a href="index.asp?page=systems" class="nav-item active"><span class="icon">&#128268;</span> 系统管理</a>
                <a href="index.asp?page=apis" class="nav-item"><span class="icon">&#128279;</span> API 管理</a>
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
                <h3><%= If id<>"" Then Response.Write "编辑系统" Else Response.Write "新增系统" %></h3>
                <div class="header-right"><span>管理员: <%= GetUserName() %></span><a href="logout.asp" class="btn btn-danger">退出</a></div>
            </div>
            <div class="page-content">
                <div class="card">
                    <% If msg <> "" Then %><div class="alert alert-error"><%= msg %></div><% End If %>
                    <form method="post" action="">
                        <div class="form-group"><label>系统名称 *</label><input type="text" name="name" value="<%= EscapeHtml(name) %>" required></div>
                        <div class="form-group"><label>系统类型</label>
                            <select name="type">
                                <option value="ERP"<% If sysType="ERP" Then Response.Write " selected" %>>ERP</option>
                                <option value="CRM"<% If sysType="CRM" Then Response.Write " selected" %>>CRM</option>
                                <option value="HRM"<% If sysType="HRM" Then Response.Write " selected" %>>HRM</option>
                                <option value="OA"<% If sysType="OA" Then Response.Write " selected" %>>OA</option>
                                <option value="WMS"<% If sysType="WMS" Then Response.Write " selected" %>>WMS</option>
                                <option value="Custom"<% If sysType="Custom" Then Response.Write " selected" %>>自定义</option>
                            </select>
                        </div>
                        <div class="form-group"><label>接入协议</label>
                            <select name="protocol">
                                <option value="REST"<% If protocol="REST" Then Response.Write " selected" %>>REST</option>
                                <option value="SOAP"<% If protocol="SOAP" Then Response.Write " selected" %>>SOAP</option>
                                <option value="gRPC"<% If protocol="gRPC" Then Response.Write " selected" %>>gRPC</option>
                                <option value="AMQP"<% If protocol="AMQP" Then Response.Write " selected" %>>AMQP</option>
                                <option value="Webhook"<% If protocol="Webhook" Then Response.Write " selected" %>>Webhook</option>
                            </select>
                        </div>
                        <div class="form-group"><label>Endpoint *</label><input type="text" name="endpoint" value="<%= EscapeHtml(endpoint) %>" placeholder="https://..." required></div>
                        <div class="form-group"><label>状态</label>
                            <select name="status">
                                <option value="1"<% If status=1 Or status="" Then Response.Write " selected" %>>启用</option>
                                <option value="0"<% If status=0 Then Response.Write " selected" %>>禁用</option>
                            </select>
                        </div>
                        <button type="submit" class="btn btn-primary">保存</button>
                        <a href="index.asp?page=systems" class="btn">返回</a>
                    </form>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
<% CloseConn() %>