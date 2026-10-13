<%
' ============================================
' 企业多系统连接中枢 - 消息队列处理
' 文件: queue_process.asp
' 功能: 处理队列中的消息，执行路由/转换/推送
' ============================================
Response.Charset = "UTF-8"
Session.CodePage = 65001
Response.ContentType = "application/json"

<!--#include file="inc/conn.asp" -->
<!--#include file="inc/engine.asp" -->
<!--#include file="inc/queue.asp" -->

Dim queueName, maxCount
queueName = Request.QueryString("queue")
maxCount = Request.QueryString("count")
If maxCount = "" Or Not IsNumeric(maxCount) Then maxCount = 10
If queueName = "" Then queueName = "default"

Dim mq, rs, processed, failed
Set mq = New MessageQueue
processed = 0
failed = 0

' 获取待处理消息
Set rs = mq.Dequeue(queueName, maxCount)

Do While Not rs.EOF
    Dim msgId, payload
    msgId = rs("id")
    payload = rs("payload")
    
    ' 标记为处理中
    mq.Processing msgId
    
    On Error Resume Next
    
    ' 解析消息内容 (简单格式: action|target|data)
    Dim parts, action, target, data
    parts = Split(payload, "|")
    If UBound(parts) >= 2 Then
        action = Trim(parts(0))
        target = Trim(parts(1))
        data = Trim(parts(2))
        
        Select Case action
            Case "ROUTE"
                ' 路由转发
                Dim httpClient
                Set httpClient = New HttpClient
                httpClient.Get target & "?" & data, 5000
                If GetStatus = 200 Then
                    mq.Success msgId
                    processed = processed + 1
                Else
                    mq.Failed msgId, "HTTP " & GetStatus & ": " & GetError
                    failed = failed + 1
                End If
                Set httpClient = Nothing
                
            Case "TRANSFORM"
                ' 数据转换
                Dim transformer
                Set transformer = New DataTransformer
                Dim result
                result = transformer.Transform(data, "$.id|$.user_id|UPPER;$.name|$.full_name")
                mq.Success msgId
                processed = processed + 1
                Set transformer = Nothing
                
            Case "SYNC"
                ' 数据同步
                Dim syncClient
                Set syncClient = New HttpClient
                syncClient.Post target, data, 5000
                If PostStatus = 200 Then
                    mq.Success msgId
                    processed = processed + 1
                Else
                    mq.Failed msgId, "HTTP " & PostStatus & ": " & PostError
                    failed = failed + 1
                End If
                Set syncClient = Nothing
                
            Case Else
                mq.Failed msgId, "未知动作: " & action
                failed = failed + 1
        End Select
    Else
        mq.Failed msgId, "消息格式错误"
        failed = failed + 1
    End If
    
    On Error GoTo 0
    rs.MoveNext
Loop

rs.Close

' 记录日志
Dim logger
Set logger = New Logger
logger.Info "队列处理完成: " & queueName & ", 成功: " & processed & ", 失败: " & failed, "system"

Response.Write "{""success"": true, ""queue"": """ & queueName & """, ""processed"": " & processed & ", ""failed"": " & failed & "}"

Set mq = Nothing
Set logger = Nothing
CloseConn()
%>