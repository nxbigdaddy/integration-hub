<%
' ============================================
' 企业多系统连接中枢 - 消息队列模拟
' 文件: inc/queue.asp
' 功能: 用数据库表模拟消息队列
' ============================================

Class MessageQueue
    ' 发送消息到队列
    Public Sub Enqueue(queueName, payload, priority)
        On Error Resume Next
        Dim sql
        sql = "INSERT INTO message_queue (queue_name, payload, priority, status, created_at) VALUES ('" & queueName & "', '" & Replace(payload, "'", "''") & "', " & priority & ", 'pending', '" & Now() & "')"
        conn.Execute sql
        On Error GoTo 0
    End Sub
    
    ' 获取待处理消息
    Public Function Dequeue(queueName, maxCount)
        Dim sql, rs
        sql = "SELECT TOP " & maxCount & " * FROM message_queue WHERE queue_name='" & queueName & "' AND status='pending' ORDER BY priority DESC, created_at ASC"
        Set rs = conn.Execute(sql)
        Set Dequeue = rs
    End Function
    
    ' 标记消息为处理中
    Public Sub Processing(msgId)
        On Error Resume Next
        conn.Execute "UPDATE message_queue SET status='processing', updated_at='" & Now() & "' WHERE id=" & msgId
        On Error GoTo 0
    End Sub
    
    ' 标记消息为成功
    Public Sub Success(msgId)
        On Error Resume Next
        conn.Execute "UPDATE message_queue SET status='completed', updated_at='" & Now() & "' WHERE id=" & msgId
        On Error GoTo 0
    End Sub
    
    ' 标记消息为失败
    Public Sub Failed(msgId, errorMsg)
        On Error Resume Next
        Dim sql
        sql = "UPDATE message_queue SET status='failed', error_msg='" & Replace(errorMsg, "'", "''") & "', retry_count=retry_count+1, updated_at='" & Now() & "' WHERE id=" & msgId
        conn.Execute sql
        On Error GoTo 0
    End Sub
    
    ' 重试失败消息
    Public Sub RetryFailed(queueName, maxRetries)
        On Error Resume Next
        conn.Execute "UPDATE message_queue SET status='pending', error_msg='', updated_at='" & Now() & "' WHERE queue_name='" & queueName & "' AND status='failed' AND retry_count < " & maxRetries
        On Error GoTo 0
    End Sub
    
    ' 获取队列统计
    Public Function GetStats(queueName)
        Dim sql, rs, stats
        sql = "SELECT status, COUNT(*) as cnt FROM message_queue WHERE queue_name='" & queueName & "' GROUP BY status"
        Set rs = conn.Execute(sql)
        Set stats = Server.CreateObject("Scripting.Dictionary")
        stats.Add "pending", 0
        stats.Add "processing", 0
        stats.Add "completed", 0
        stats.Add "failed", 0
        
        Do While Not rs.EOF
            stats(rs("status")) = rs("cnt")
            rs.MoveNext
        Loop
        rs.Close
        
        Set GetStats = stats
    End Function
End Class
%>