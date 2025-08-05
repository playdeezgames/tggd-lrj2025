Friend Class EastDirectionTypeDescriptor
    Inherits DirectionTypeDescriptor

    Public Sub New()
        MyBase.New(
            Business.DirectionType.East,
            1,
            0,
            Business.DirectionType.West)
    End Sub

    Public Overrides Function GetDoorFromLocation(map As IMap) As (Column As Integer, Row As Integer)
        Return (map.Columns - 1, map.Rows \ 2)
    End Function

    Public Overrides Function GetDoorToLocation(map As IMap) As (Column As Integer, Row As Integer)
        Return (1, map.Rows \ 2)
    End Function
End Class
