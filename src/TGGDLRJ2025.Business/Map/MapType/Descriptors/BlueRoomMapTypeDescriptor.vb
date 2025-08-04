Imports TGGD.Business

Friend Class BlueRoomMapTypeDescriptor
    Inherits MapTypeDescriptor

    Public Sub New()
        MyBase.New(
            Business.MapType.BlueRoom,
            7, 7)
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
        Dim location = RNG.FromEnumerable(map.Locations.Where(Function(x) x.LocationType = LocationType.Floor))
        map.World.Avatar = map.World.CreateCharacter(CharacterType.N00b, location)
    End Sub
End Class
