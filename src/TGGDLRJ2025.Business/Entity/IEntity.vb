Public Interface IEntity
    Sub SetStatistic(statisticType As String, statisticValue As Integer?)
    Function GetStatistic(statisticType As String) As Integer?
End Interface
