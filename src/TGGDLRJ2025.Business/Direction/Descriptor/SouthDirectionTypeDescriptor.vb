Friend Class SouthDirectionTypeDescriptor
    Inherits DirectionTypeDescriptor

    Public Sub New()
        MyBase.New(Business.DirectionType.South, 0, 1, Business.DirectionType.North)
    End Sub

    Public Overrides Function GetDoorFromLocation(map As IMap) As (Column As Integer, Row As Integer)
        Return (map.Columns \ 2, map.Rows - 1)
    End Function

    Public Overrides Function GetDoorToLocation(map As IMap) As (Column As Integer, Row As Integer)
        Return (map.Columns \ 2, 1)
    End Function
End Class
