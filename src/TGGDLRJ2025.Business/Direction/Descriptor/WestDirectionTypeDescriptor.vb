Friend Class WestDirectionTypeDescriptor
    Inherits DirectionTypeDescriptor

    Public Sub New()
        MyBase.New(
            Business.DirectionType.West,
            -1,
            0,
            Business.DirectionType.East)
    End Sub

    Public Overrides Function GetDoorFromLocation(map As IMap) As (Column As Integer, Row As Integer)
        Return (0, map.Rows \ 2)
    End Function

    Public Overrides Function GetDoorToLocation(map As IMap) As (Column As Integer, Row As Integer)
        Return (map.Columns - 2, map.Rows \ 2)
    End Function
End Class
