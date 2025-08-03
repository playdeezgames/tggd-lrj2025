Friend Class BlueRoomMapTypeDescriptor
    Inherits MapTypeDescriptor

    Public Sub New()
        MyBase.New(
            Business.MapType.BlueRoom,
            6, 6)
    End Sub

    Friend Overrides Sub Initialize(map As IMap)
        For Each column In Enumerable.Range(0, map.Columns)
            For Each row In Enumerable.Range(0, map.Rows)
                Dim locationType = Business.LocationType.Floor
                If column = 0 OrElse row = 0 OrElse column = map.Columns - 1 OrElse row = map.Rows - 1 Then
                    locationType = Business.LocationType.BlueWall
                End If
                map.World.CreateLocation(map, column, row, locationType)
            Next
        Next
    End Sub
End Class
