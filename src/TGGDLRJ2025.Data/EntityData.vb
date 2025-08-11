Public MustInherit Class EntityData
    Public Property Statistics As New Dictionary(Of String, Integer)
    Public Property StatisticMinimums As New Dictionary(Of String, Integer)
    Public Property StatisticMaximums As New Dictionary(Of String, Integer)
    Public Property Tags As New HashSet(Of String)
End Class
