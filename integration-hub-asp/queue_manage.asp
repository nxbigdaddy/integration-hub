<%
' ============================================
' 企业多系统连接中枢 - 队列管理
' 文件: queue_manage.asp
' 功能: 查看队列状态、处理消息、重试失败消息
' ============================================
Response.Charset = "UTF-8"
Session.CodePage = 65001

<!--#include file="inc/conn.asp" -->
<!--#include file="inc/engine.asp" -->
<!--#include file="inc/queue.asp" -->

CheckLogin()

Dim action, queueName
action = Request.QueryString("action")
queueName = Request.QueryString("queue")
If queueName = "" Then queueName = "default"

If action = "process" Then
    Response.Redirect "queue_process.asp?queue=" & queueName & "&count=20"
ElseIf action = "retry" Then
    Dim mq
    Set mq = New MessageQueue
    mq.RetryFailed queueName, 3
    Set mq = Nothing
    Response.Redirect "queue_manage.asp?queue=" & queueName
End If

' 获取队列统计
Dim mq, stats
Set mq = New MessageQueue
Set stats = mq.GetStats(queueName)
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>队列管理 - 集成中枢</title>
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
                <a href="index.asp?page=routes" class="nav-item"><span class="icon">&#128739;</span> 路由配置</a>
                <a href="index.asp?page=monitor" class="nav-item active"><span class="icon">&#128200;</span> 监控中心</a>
                <a href="index.asp?page=logs" class="nav-item"><span class="icon">&#128221;</span> 日志审计</a>
                <a href="index.asp?page=settings" class="nav-item"><span class="icon">&#9881;</span> 系统设置</a>
            </ul>
        </div>
        <div class="main-content">
            <div class="header">
                <h3>消息队列管理</h3>
                <div class="header-right"><span>管理员: <%= GetUserName() %></span><a href="logout.asp" class="btn btn-danger">退出</a></div>
            </div>
            <div class="page-content">
                <div class="stats-grid">
                    <div class="stat-card"><div class="label">待处理</div><div class="value"><%= stats("pending") %></div></div>
                    <div class="stat-card"><div class="label">处理中</div><div class="value"><%= stats("processing") %></div></div>
                    <div class="stat-card"><div class="label">已完成</div><div class="value"><%= stats("completed") %></div></div>
                    <div class="stat-card"><div class="label">失败</div><div class="value"><%= stats("failed") %></div></div>
                </div>
                <div class="card">
                    <div class="toolbar">
                        <h3>消息列表 (<%= queueName %>)</h3>
                        <div>
                            <a href="queue_manage.asp?action=process&queue=<%= queueName %>" class="btn btn-primary">处理消息</a>
                            <a href="queue_manage.asp?action=retry&queue=<%= queueName %>" class="btn btn-warning">重试失败</a>
                        </div>
                    </div>
                    <table>
                        <thead><tr><th>ID</th><th>负载</th><th>优先级</th><th>状态</th><th>重试次数</th><th>创建时间</th></tr></thead>
                        <tbody>
<%
                    Dim rs
                    Set rs = GetRecordset("SELECT TOP 50 * FROM message_queue WHERE queue_name='" & queueName & "' ORDER BY id DESC")
                    Do While Not rs.EOF
%>
                            <tr>
                                <td><%= rs("id") %></td>
                                <td style="max-width:300px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;"><%= Left(rs("payload"), 100) %></td>
                                <td><%= rs("priority") %></td>
                                <td>
<%
                                    Select Case rs("status")
                                        Case "pending": Response.Write "<span class='status active'>待处理</span>"
                                        Case "processing": Response.Write "<span class='status' style='background:#e6f7ff;color:#1890ff'>处理中</span>"
                                        Case "completed": Response.Write "<span class='status active'>已完成</span>"
                                        Case "failed": Response.Write "<span class='status inactive'>失败</span>"
                                    End Select
%>
                                </td>
                                <td><%= rs("retry_count") %></td>
                                <td><%= FormatDate(rs("created_at")) %></td>
                            </tr>
<%
                        rs.MoveNext
                    Loop
                    rs.Close
%>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
<%
Set mq = Nothing
Set stats = Nothing
CloseConn()
%>