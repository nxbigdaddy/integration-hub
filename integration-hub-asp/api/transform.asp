<%
' ============================================
' 企业多系统连接中枢 - 数据转换 API
' 文件: api/transform.asp
' 功能: 接收源数据和映射规则，执行转换
' ============================================
Response.Charset = "UTF-8"
Session.CodePage = 65001
Response.ContentType = "application/json"

<!--#include file="../inc/conn.asp" -->
<!--#include file="../inc/engine.asp" -->

Dim sourceJson, rulesJson
sourceJson = Request.Form("source")
rulesJson = Request.Form("rules")

If sourceJson = "" Or rulesJson = "" Then
    Response.Status = "400 Bad Request"
    Response.Write "{""success"": false, ""error"": ""缺少 source 或 rules 参数""}"
    Response.End
End If

' 执行转换
Dim transformer, result
Set transformer = New DataTransformer
result = transformer.Transform(sourceJson, rulesJson)

' 记录日志
Dim logger
Set logger = New Logger
logger.Info "数据转换执行: " & Left(sourceJson, 100), "system"

Response.Write "{""success"": true, ""result"": " & result & "}"

Set transformer = Nothing
Set logger = Nothing
CloseConn()
%>