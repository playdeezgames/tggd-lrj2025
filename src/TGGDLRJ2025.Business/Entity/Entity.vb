Imports TGGDLRJ2025.Data

Public MustInherit Class Entity
    Implements IEntity
    Protected ReadOnly data As WorldData
    Protected MustOverride ReadOnly Property EntityData As EntityData
    Sub New(data As WorldData)
        Me.data = data
    End Sub

    Public Sub SetStatistic(statisticType As String, statisticValue As Integer?) Implements IEntity.SetStatistic
        If statisticValue.HasValue Then
            EntityData.Statistics(statisticType) = statisticValue.Value
        Else
            EntityData.Statistics.Remove(statisticType)
        End If
    End Sub
End Class
