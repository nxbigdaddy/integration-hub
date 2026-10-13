<%
Response.Charset = "UTF-8"
Session.CodePage = 65001
<!--#include file="inc/conn.asp" -->
CheckLogin()

Dim id, action
id = Request.QueryString("id")
action = Request.QueryString("action")

If id <> "" And action <> "" Then
    Dim newStatus
    If action = "enable" Then newStatus = 1 Else newStatus = 0
    ExecuteSQL "UPDATE mappings SET status=" & newStatus & " WHERE id=" & id
End If

Response.Redirect "index.asp?page=mapping"
CloseConn()
%>