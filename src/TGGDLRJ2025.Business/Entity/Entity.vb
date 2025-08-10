Imports TGGDLRJ2025.Data

Public MustInherit Class Entity
    Implements IEntity
    Protected ReadOnly data As WorldData
    Protected ReadOnly sfxQueue As Queue(Of String)
    Protected MustOverride ReadOnly Property EntityData As EntityData
    Sub New(data As WorldData, sfxQueue As Queue(Of String))
        Me.data = data
        Me.sfxQueue = sfxQueue
    End Sub

    Public Sub SetStatistic(statisticType As String, statisticValue As Integer?) Implements IEntity.SetStatistic
        If statisticValue.HasValue Then
            EntityData.Statistics(statisticType) = statisticValue.Value
        Else
            EntityData.Statistics.Remove(statisticType)
        End If
    End Sub

    Public Function GetStatistic(statisticType As String) As Integer? Implements IEntity.GetStatistic
        Dim statisticValue As Integer = 0
        If EntityData.Statistics.TryGetValue(statisticType, statisticValue) Then
            Return Math.Clamp(
                statisticValue,
                GetStatisticMinimum(statisticType),
                GetStatisticMaximum(statisticType))
        End If
        Return Nothing
    End Function

    Public Sub SetStatisticMinimum(statisticType As String, minimumValue As Integer?) Implements IEntity.SetStatisticMinimum
        If minimumValue.HasValue Then
            EntityData.StatisticMinimums(statisticType) = minimumValue.Value
        Else
            EntityData.StatisticMinimums.Remove(statisticType)
        End If
    End Sub

    Public Sub SetStatisticMaximum(statisticType As String, maximumValue As Integer?) Implements IEntity.SetStatisticMaximum
        If maximumValue.HasValue Then
            EntityData.StatisticMaximums(statisticType) = maximumValue.Value
        Else
            EntityData.StatisticMaximums.Remove(statisticType)
        End If
    End Sub

    Public Function GetStatisticMaximum(statisticType As String) As Integer Implements IEntity.GetStatisticMaximum
        Dim result As Integer = Integer.MaxValue
        If EntityData.StatisticMaximums.TryGetValue(statisticType, result) Then
            Return result
        End If
        Return Integer.MaxValue
    End Function

    Public Function GetStatisticMinimum(statisticType As String) As Integer Implements IEntity.GetStatisticMinimum
        Dim result As Integer = Integer.MinValue
        If EntityData.StatisticMinimums.TryGetValue(statisticType, result) Then
            Return result
        End If
        Return Integer.MinValue
    End Function

    Public Function ChangeStatistic(statisticType As String, delta As Integer) As Integer? Implements IEntity.ChangeStatistic
        SetStatistic(statisticType, If(GetStatistic(statisticType), 0) + delta)
        Return GetStatistic(statisticType)
    End Function
End Class
