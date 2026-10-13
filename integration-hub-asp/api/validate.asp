<%
' ============================================
' 企业多系统连接中枢 - 数据校验 API
' 文件: api/validate.asp
' 功能: 接收数据和校验规则，执行校验
' ============================================
Response.Charset = "UTF-8"
Session.CodePage = 65001
Response.ContentType = "application/json"

<!--#include file="../inc/conn.asp" -->
<!--#include file="../inc/engine.asp" -->

Dim dataJson, rulesJson
dataJson = Request.Form("data")
rulesJson = Request.Form("rules")

If dataJson = "" Or rulesJson = "" Then
    Response.Status = "400 Bad Request"
    Response.Write "{""success"": false, ""error"": ""缺少 data 或 rules 参数""}"
    Response.End
End If

' 执行校验
Dim validator, isValid
Set validator = New ValidationEngine
isValid = validator.Validate(dataJson, rulesJson)

' 记录日志
Dim logger
Set logger = New Logger
If isValid Then
    logger.Info "数据校验通过: " & Left(dataJson, 100), "system"
Else
    logger.Warn "数据校验失败: " & Left(dataJson, 100), "system"
End If

Response.Write "{""success"": true, ""valid"": " & LCase(CStr(isValid)) & "}"

Set validator = Nothing
Set logger = Nothing
CloseConn()
%>