<%
' ============================================
' 企业多系统连接中枢 - 路由 API 端点
' 文件: api/route.asp
' 功能: 接收请求，匹配路由，转发到目标服务
' ============================================
Response.Charset = "UTF-8"
Session.CodePage = 65001
Response.ContentType = "application/json"

<!--#include file="../inc/conn.asp" -->
<!--#include file="../inc/engine.asp" -->

Dim method, path, headers, body
method = Request.ServerVariables("REQUEST_METHOD")
path = Request.QueryString("path")
body = Request.Form("body")

If path = "" Then
    Response.Status = "400 Bad Request"
    Response.Write "{""success"": false, ""error"": ""缺少 path 参数""}"
    Response.End
End If

' 构建 Headers 字典
Set headers = Server.CreateObject("Scripting.Dictionary")
Dim key
For Each key In Request.ServerVariables
    If Left(key, 5) = "HTTP_" Then
        Dim headerName
        headerName = Replace(Mid(key, 6), "_", "-")
        headers.Add headerName, Request.ServerVariables(key)
    End If
Next

' 执行路由
Dim engine, target
Set engine = New RouteEngine
engine.LoadRules
target = engine.Resolve(path, headers)

If target <> "" Then
    ' 记录日志
    Dim logger
    Set logger = New Logger
    logger.Info "路由匹配成功: " & path & " -> " & target, "system"
    
    Response.Write "{""success"": true, ""target"": """ & target & """, ""path"": """ & path & """}"
Else
    Response.Status = "404 Not Found"
    Response.Write "{""success"": false, ""error"": ""未找到匹配的路由""}"
End If

Set engine = Nothing
Set headers = Nothing
CloseConn()
%>