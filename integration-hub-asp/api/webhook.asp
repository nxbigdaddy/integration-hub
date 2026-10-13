<%
' ============================================
' 企业多系统连接中枢 - Webhook 接收端点
' 文件: api/webhook.asp
' 功能: 接收外部系统推送的数据，入队处理
' ============================================
Response.Charset = "UTF-8"
Session.CodePage = 65001
Response.ContentType = "application/json"

<!--#include file="../inc/conn.asp" -->
<!--#include file="../inc/engine.asp" -->
<!--#include file="../inc/queue.asp" -->

Dim systemName, payload, queue
systemName = Request.QueryString("system")
payload = Request.Form("payload")

If systemName = "" Or payload = "" Then
    Response.Status = "400 Bad Request"
    Response.Write "{""success"": false, ""error"": ""缺少 system 或 payload 参数""}"
    Response.End
End If

' 入队
Dim mq
Set mq = New MessageQueue
mq.Enqueue systemName, payload, 1

' 记录日志
Dim logger
Set logger = New Logger
logger.Info "接收 Webhook 数据: " & systemName & ", 长度: " & Len(payload), "system"

Response.Write "{""success"": true, ""message"": ""数据已入队""}"

Set mq = Nothing
Set logger = Nothing
CloseConn()
%>