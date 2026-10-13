<%
' ============================================
' 企业多系统连接中枢 - 集成引擎核心
' 文件: inc/engine.asp
' 功能: 路由引擎、数据转换、数据校验
' ============================================

' ============================================
' 1. 路由引擎
' ============================================
Class RouteEngine
    Private rules
    
    Private Sub Class_Initialize()
        Set rules = Server.CreateObject("Scripting.Dictionary")
    End Sub
    
    ' 加载路由规则
    Public Sub LoadRules()
        Dim rs, sql
        sql = "SELECT * FROM routes WHERE status=1 ORDER BY priority DESC"
        Set rs = conn.Execute(sql)
        rules.RemoveAll
        Do While Not rs.EOF
            rules.Add CStr(rs("id")), Array(rs("match_type"), rs("condition"), rs("target"), rs("priority"))
            rs.MoveNext
        Loop
        rs.Close
    End Sub
    
    ' 匹配路由
    Public Function Resolve(path, headers)
        Dim key, rule, matchType, condition, target
        Resolve = ""
        
        For Each key In rules
            rule = rules(key)
            matchType = rule(0)
            condition = rule(1)
            target = rule(2)
            
            Select Case matchType
                Case "prefix"
                    If Left(path, Len(condition)) = condition Then
                        Resolve = target
                        Exit Function
                    End If
                Case "exact"
                    If path = condition Then
                        Resolve = target
                        Exit Function
                    End If
                Case "header"
                    Dim parts, headerKey, headerVal
                    parts = Split(condition, ": ")
                    If UBound(parts) >= 1 Then
                        headerKey = Trim(parts(0))
                        headerVal = Trim(parts(1))
                        If headers.Exists(headerKey) And headers(headerKey) = headerVal Then
                            Resolve = target
                            Exit Function
                        End If
                    End If
            End Select
        Next
    End Function
    
    Private Sub Class_Terminate()
        Set rules = Nothing
    End Sub
End Class

' ============================================
' 2. 数据转换引擎
' ============================================
Class DataTransformer
    ' 简单 JSON 字段提取 (不支持嵌套路径，仅支持 $.fieldname)
    Public Function ExtractField(jsonStr, fieldPath)
        Dim fieldName, pattern, reg, matches
        ExtractField = ""
        
        ' 提取字段名 (去掉 $.)
        fieldName = Replace(fieldPath, "$.", "")
        
        ' 简单正则匹配 "fieldName":"value" 或 "fieldName":value
        Set reg = New RegExp
        reg.Pattern = """" & fieldName & """:\s*""?([^"",}]+)""?"
        reg.IgnoreCase = True
        reg.Global = False
        
        If reg.Test(jsonStr) Then
            Set matches = reg.Execute(jsonStr)
            If matches.Count > 0 Then
                ExtractField = Trim(matches(0).SubMatches(0))
            End If
        End If
        
        Set reg = Nothing
    End Function
    
    ' 应用转换
    Public Function ApplyTransform(value, expression)
        If expression = "" Or IsNull(expression) Then
            ApplyTransform = value
            Exit Function
        End If
        
        Select Case UCase(expression)
            Case "UPPER"
                ApplyTransform = UCase(value)
            Case "LOWER"
                ApplyTransform = LCase(value)
            Case "TRIM"
                ApplyTransform = Trim(value)
            Case "MD5"
                ApplyTransform = SimpleHash(value)
            Case Else
                ' 支持简单表达式如 "prefix('CRM_', $)"
                If InStr(expression, "prefix(") > 0 Then
                    Dim prefixVal
                    prefixVal = Mid(expression, InStr(expression, "'") + 1)
                    prefixVal = Left(prefixVal, InStr(prefixVal, "'") - 1)
                    ApplyTransform = prefixVal & value
                Else
                    ApplyTransform = value
                End If
        End Select
    End Function
    
    ' 简单哈希 (非标准 MD5，仅用于演示)
    Private Function SimpleHash(str)
        Dim i, hash
        hash = 0
        For i = 1 To Len(str)
            hash = hash + Asc(Mid(str, i, 1)) * i
        Next
        SimpleHash = Right("00000000" & Hex(hash), 8)
    End Function
    
    ' 执行映射转换
    Public Function Transform(sourceJson, rulesJson)
        Dim result, rules, i, rule, sourcePath, targetPath, transformExpr, value
        
        ' 解析规则 (简单格式: sourcePath|targetPath|transform)
        rules = Split(rulesJson, ";")
        result = "{"
        
        For i = 0 To UBound(rules)
            If Trim(rules(i)) <> "" Then
                Dim parts
                parts = Split(Trim(rules(i)), "|")
                If UBound(parts) >= 1 Then
                    sourcePath = Trim(parts(0))
                    targetPath = Trim(parts(1))
                    If UBound(parts) >= 2 Then
                        transformExpr = Trim(parts(2))
                    Else
                        transformExpr = ""
                    End If
                    
                    value = ExtractField(sourceJson, sourcePath)
                    If value <> "" Then
                        value = ApplyTransform(value, transformExpr)
                        If i > 0 Then result = result & ", "
                        result = result & """" & Replace(targetPath, "$.", "") & """: """ & value & """"
                    End If
                End If
            End If
        Next
        
        result = result & "}"
        Transform = result
    End Function
End Class

' ============================================
' 3. 数据校验引擎
' ============================================
Class ValidationEngine
    Public Function Validate(jsonStr, rulesJson)
        Dim rules, i, rule, result
        result = True
        
        rules = Split(rulesJson, ";")
        
        For i = 0 To UBound(rules)
            If Trim(rules(i)) <> "" Then
                Dim parts, fieldPath, ruleType, ruleParam
                parts = Split(Trim(rules(i)), "|")
                
                If UBound(parts) >= 2 Then
                    fieldPath = Trim(parts(0))
                    ruleType = UCase(Trim(parts(1)))
                    ruleParam = Trim(parts(2))
                    
                    Dim transformer
                    Set transformer = New DataTransformer
                    Dim value
                    value = transformer.ExtractField(jsonStr, fieldPath)
                    Set transformer = Nothing
                    
                    Select Case ruleType
                        Case "REQUIRED"
                            If value = "" Then
                                result = False
                                Exit For
                            End If
                        Case "REGEX"
                            If value <> "" Then
                                Set reg = New RegExp
                                reg.Pattern = ruleParam
                                reg.IgnoreCase = True
                                If Not reg.Test(value) Then
                                    result = False
                                    Exit For
                                End If
                                Set reg = Nothing
                            End If
                        Case "MIN_LENGTH"
                            If Len(value) < CInt(ruleParam) Then
                                result = False
                                Exit For
                            End If
                        Case "MAX_LENGTH"
                            If Len(value) > CInt(ruleParam) Then
                                result = False
                                Exit For
                            End If
                        Case "EMAIL"
                            If value <> "" Then
                                Set reg = New RegExp
                                reg.Pattern = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
                                If Not reg.Test(value) Then
                                    result = False
                                    Exit For
                                End If
                                Set reg = Nothing
                            End If
                        Case "PHONE"
                            If value <> "" Then
                                Set reg = New RegExp
                                reg.Pattern = "^1[3-9]\d{9}$"
                                If Not reg.Test(value) Then
                                    result = False
                                    Exit For
                                End If
                                Set reg = Nothing
                            End If
                    End Select
                End If
            End If
        Next
        
        Validate = result
    End Function
End Class

' ============================================
' 4. 日志记录器
' ============================================
Class Logger
    Public Sub Write(level, message, userName)
        On Error Resume Next
        Dim sql
        sql = "INSERT INTO logs (level, message, user_name, created_at) VALUES ('" & level & "', '" & Replace(message, "'", "''") & "', '" & userName & "', '" & Now() & "')"
        conn.Execute sql
        On Error GoTo 0
    End Sub
    
    Public Sub Info(message, userName)
        Write "INFO", message, userName
    End Sub
    
    Public Sub Warn(message, userName)
        Write "WARN", message, userName
    End Sub
    
    Public Sub ErrorLog(message, userName)
        Write "ERROR", message, userName
    End Sub
End Class

' ============================================
' 5. HTTP 客户端
' ============================================
Class HttpClient
    Private xmlHttp
    
    Private Sub Class_Initialize()
        Set xmlHttp = Server.CreateObject("MSXML2.ServerXMLHTTP.6.0")
    End Sub
    
    ' GET 请求
    Public Function Get(url, timeoutMs)
        On Error Resume Next
        xmlHttp.Open "GET", url, False
        xmlHttp.SetRequestHeader "Content-Type", "application/json"
        xmlHttp.SetTimeouts timeoutMs, timeoutMs, timeoutMs, timeoutMs
        xmlHttp.Send
        
        If Err.Number = 0 Then
            Get = xmlHttp.responseText
            GetStatus = xmlHttp.Status
        Else
            Get = ""
            GetStatus = 0
            GetError = Err.Description
        End If
        On Error GoTo 0
    End Function
    
    ' POST 请求
    Public Function Post(url, data, timeoutMs)
        On Error Resume Next
        xmlHttp.Open "POST", url, False
        xmlHttp.SetRequestHeader "Content-Type", "application/json"
        xmlHttp.SetTimeouts timeoutMs, timeoutMs, timeoutMs, timeoutMs
        xmlHttp.Send data
        
        If Err.Number = 0 Then
            Post = xmlHttp.responseText
            PostStatus = xmlHttp.Status
        Else
            Post = ""
            PostStatus = 0
            PostError = Err.Description
        End If
        On Error GoTo 0
    End Function
    
    Private Sub Class_Terminate()
        Set xmlHttp = Nothing
    End Sub
End Class

' 全局变量
Public GetStatus, GetError, PostStatus, PostError
%>