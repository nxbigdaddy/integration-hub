<%
' ============================================
' 企业多系统连接中枢 - 数据映射编辑
' 文件: mapping_edit.asp
' ============================================
Response.Charset = "UTF-8"
Session.CodePage = 65001
<!--#include file="inc/conn.asp" -->
CheckLogin()

Dim id, name, sourceSys, targetSys, rules, status, msg
id = Request.QueryString("id")

If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    name = Trim(Request.Form("name"))
    sourceSys = Trim(Request.Form("source_sys"))
    targetSys = Trim(Request.Form("target_sys"))
    rules = Trim(Request.Form("rules"))
    status = Request.Form("status")
    
    If name <> "" Then
        If id <> "" Then
            ExecuteSQL "UPDATE mappings SET name='" & name & "', source_sys='" & sourceSys & "', target_sys='" & targetSys & "', rules='" & Replace(rules, "'", "''") & "', status=" & status & " WHERE id=" & id
        Else
            ExecuteSQL "INSERT INTO mappings (name, source_sys, target_sys, rules, status, created_at) VALUES ('" & name & "', '" & sourceSys & "', '" & targetSys & "', '" & Replace(rules, "'", "''") & "', " & status & ", '" & Now() & "')"
        End If
        Response.Redirect "index.asp?page=mapping&msg=saved"
    Else
        msg = "请填写映射名称"
    End If
End If

If id <> "" Then
    Dim rs
    Set rs = GetRecordset("SELECT * FROM mappings WHERE id=" & id)
    If Not rs.EOF Then
        name = rs("name")
        sourceSys = rs("source_sys")
        targetSys = rs("target_sys")
        rules = rs("rules")
        status = rs("status")
    End If
    rs.Close
End If
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title><%= If id<>"" Then Response.Write "编辑" Else Response.Write "创建" %>数据映射 - 集成中枢</title>
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
                <a href="sync.asp" class="nav-item"><span class="icon">&#128256;</span> 数据同步</a>
                <a href="queue_manage.asp" class="nav-item"><span class="icon">&#128230;</span> 队列管理</a>
                <a href="test_api.asp" class="nav-item"><span class="icon">&#128300;</span> API 测试</a>
            </ul>
        </div>
        <div class="main-content">
            <div class="header">
                <h3><%= If id<>"" Then Response.Write "编辑数据映射" Else Response.Write "创建数据映射" %></h3>
                <div class="header-right"><span>管理员: <%= GetUserName() %></span><a href="logout.asp" class="btn btn-danger">退出</a></div>
            </div>
            <div class="page-content">
                <div class="card">
                    <% If msg <> "" Then %><div class="alert alert-error"><%= msg %></div><% End If %>
                    <form method="post" action="">
                        <div class="form-group"><label>映射名称 *</label><input type="text" name="name" value="<%= EscapeHtml(name) %>" placeholder="如: ERP&#8594;CRM 客户同步" required></div>
                        <div class="form-group"><label>源系统</label>
                            <select name="source_sys">
                                <option value="SAP ERP"<% If sourceSys="SAP ERP" Then Response.Write " selected" %>>SAP ERP</option>
                                <option value="Salesforce"<% If sourceSys="Salesforce" Then Response.Write " selected" %>>Salesforce</option>
                                <option value="Workday"<% If sourceSys="Workday" Then Response.Write " selected" %>>Workday</option>
                                <option value="富勒 WMS"<% If sourceSys="富勒 WMS" Then Response.Write " selected" %>>富勒 WMS</option>
                            </select>
                        </div>
                        <div class="form-group"><label>目标系统</label>
                            <select name="target_sys">
                                <option value="Salesforce"<% If targetSys="Salesforce" Then Response.Write " selected" %>>Salesforce</option>
                                <option value="SAP ERP"<% If targetSys="SAP ERP" Then Response.Write " selected" %>>SAP ERP</option>
                                <option value="钉钉 OA"<% If targetSys="钉钉 OA" Then Response.Write " selected" %>>钉钉 OA</option>
                                <option value="富勒 WMS"<% If targetSys="富勒 WMS" Then Response.Write " selected" %>>富勒 WMS</option>
                            </select>
                        </div>
                        <div class="form-group"><label>映射规则 (JSON)</label><textarea name="rules" placeholder='[{"source": "$.cust_id", "target": "$.contact_id"}]'><%= EscapeHtml(rules) %></textarea></div>
                        <div class="form-group"><label>状态</label>
                            <select name="status">
                                <option value="1"<% If status=1 Or status="" Then Response.Write " selected" %>>启用</option>
                                <option value="0"<% If status=0 Then Response.Write " selected" %>>禁用</option>
                            </select>
                        </div>
                        <button type="submit" class="btn btn-primary">保存</button>
                        <a href="index.asp?page=mapping" class="btn">返回</a>
                    </form>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
<% CloseConn() %>