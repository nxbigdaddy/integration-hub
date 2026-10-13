<%
' ============================================
' 企业多系统连接中枢 - 登录页面
' 文件: login.asp
' ============================================
Response.Charset = "UTF-8"
Session.CodePage = 65001

If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    Dim username, password
    username = Trim(Request.Form("username"))
    password = YOUR_PASSWORD"password"))
    
    ' 验证用户 (演示用硬编码，生产环境应查数据库)
    If username = "admin" And password = "YOUR_PASSWORD" Then
        Session("username") = "admin"
        Session("role") = "admin"
        Session("login_time") = Now()
        Response.Redirect "index.asp"
    ElseIf username = "user" And password = "YOUR_PASSWORD" Then
        Session("username") = "user"
        Session("role") = "user"
        Session("login_time") = Now()
        Response.Redirect "index.asp"
    Else
        Dim loginError
        loginError = "用户名或密码错误"
    End If
End If

' 已登录则跳转
If Session("username") <> "" Then
    Response.Redirect "index.asp"
End If
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>登录 - 企业多系统连接中枢</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body class="login-page">
    <div class="login-container">
        <div class="login-logo">
            <h1>企业多系统连接中枢</h1>
            <p>Enterprise Integration Hub</p>
        </div>
        <form method="post" action="login.asp" class="login-form">
            <% If loginError <> "" Then %>
            <div class="alert alert-error"><%= loginError %></div>
            <% End If %>
            <div class="form-group">
                <label>用户名</label>
                <input type="text" name="username" placeholder="请输入用户名" required autofocus>
            </div>
            <div class="form-group">
                <label>密码</label>
                <input type="password" name="YOUR_PASSWORD" placeholder="请输入密码" required>
            </div>
            <button type="submit" class="btn btn-primary btn-block">登 录</button>
        </form>
        <div class="demo-info">
            <strong>演示账号:</strong><br>
            管理员: admin / admin123<br>
            普通用户: user / user123
        </div>
    </div>
</body>
</html>