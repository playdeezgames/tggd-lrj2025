Friend Class NorthDirectionTypeDescriptor
    Inherits DirectionTypeDescriptor

    Public Sub New()
        MyBase.New(Business.DirectionType.North, 0, -1, Business.DirectionType.South)
    End Sub

    Public Overrides Function GetDoorFromLocation(map As IMap) As (Column As Integer, Row As Integer)
        Return (map.Columns \ 2, 0)
    End Function

    Public Overrides Function GetDoorToLocation(map As IMap) As (Column As Integer, Row As Integer)
        Return (map.Columns \ 2, map.Rows - 2)
    End Function
End Class
