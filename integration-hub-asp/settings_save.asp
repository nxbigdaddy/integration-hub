<%
' ============================================
' 企业多系统连接中枢 - 设置保存
' 文件: settings_save.asp
' ============================================
Response.Charset = "UTF-8"
Session.CodePage = 65001
<!--#include file="inc/conn.asp" -->
CheckLogin()

If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    Dim sessionTimeout, maxLoginFail, ipWhitelist
    sessionTimeout = Trim(Request.Form("session_timeout"))
    maxLoginFail = Trim(Request.Form("max_login_fail"))
    ipWhitelist = Trim(Request.Form("ip_whitelist"))
    
    ' 保存到数据库或配置文件
    ExecuteSQL "UPDATE settings SET session_timeout=" & sessionTimeout & ", max_login_fail=" & maxLoginFail & ", ip_whitelist='" & Replace(ipWhitelist, "'", "''") & "' WHERE id=1"
    
    Session("msg") = "配置保存成功"
End If

Response.Redirect "index.asp?page=settings"
CloseConn()
%>