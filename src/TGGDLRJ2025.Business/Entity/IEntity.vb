Public Interface IEntity
    Sub SetStatistic(statisticType As String, statisticValue As Integer?)
    Sub SetStatisticMinimum(statisticType As String, minimumValue As Integer?)
    Sub SetStatisticMaximum(statisticType As String, maximumValue As Integer?)
    Function GetStatisticMaximum(statisticType As String) As Integer
    Function GetStatisticMinimum(statisticType As String) As Integer
    Function GetStatistic(statisticType As String) As Integer?
    Function ChangeStatistic(statisticType As String, delta As Integer) As Integer?
End Interface
