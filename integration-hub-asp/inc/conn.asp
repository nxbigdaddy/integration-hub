<%
' ============================================
' 企业多系统连接中枢 - 数据库连接配置
' 文件: inc/conn.asp
' ============================================

Dim conn, connStr

' Access 数据库连接 (开发/演示环境)
Dim dbPath
dbPath = Server.MapPath("../db/integration_hub.mdb")
connStr = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" & dbPath & ";"

' 创建连接
On Error Resume Next
Set conn = Server.CreateObject("ADODB.Connection")
conn.Open connStr
If Err.Number <> 0 Then
    ' 如果 Access 数据库不存在，使用内存模拟模式
    Session("db_mode") = "mock"
Else
    Session("db_mode") = "access"
End If
On Error GoTo 0

' ============================================
' 通用函数库
' ============================================

Function CheckLogin()
    If Session("username") = "" Then
        Response.Redirect "login.asp"
    End If
End Function

Function GetUserName()
    GetUserName = Session("username")
End Function

Function GetUserRole()
    GetUserRole = Session("role")
End Function

Function EscapeHtml(str)
    If IsNull(str) Or str = "" Then
        EscapeHtml = ""
    Else
        EscapeHtml = Replace(Replace(Replace(str, "&", "&amp;"), "<", "&lt;"), ">", "&gt;")
    End If
End Function

Function FormatDate(dt)
    If IsDate(dt) Then
        FormatDate = Year(dt) & "-" & Right("0" & Month(dt), 2) & "-" & Right("0" & Day(dt), 2) & " " & Right("0" & Hour(dt), 2) & ":" & Right("0" & Minute(dt), 2)
    Else
        FormatDate = "-"
    End If
End Function

Function GetStatusBadge(status)
    If status = 1 Or LCase(status) = "active" Or LCase(status) = "运行中" Then
        GetStatusBadge = "<span class='status active'>运行中</span>"
    Else
        GetStatusBadge = "<span class='status inactive'>已禁用</span>"
    End If
End Function

Sub CloseConn()
    If IsObject(conn) Then
        If conn.State = 1 Then conn.Close
        Set conn = Nothing
    End If
End Sub
%>