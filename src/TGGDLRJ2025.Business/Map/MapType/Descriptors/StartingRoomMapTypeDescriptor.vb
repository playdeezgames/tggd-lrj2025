Imports TGGD.Business

Friend Class StartingRoomMapTypeDescriptor
    Inherits MapTypeDescriptor
    Const MAP_COLUMNS = 15
    Const MAP_ROWS = 15
    Const MAP_COUNT = 1

    Public Sub New()
        MyBase.New(
            Business.MapType.StartingRoom,
            MAP_COUNT,
            MAP_COLUMNS,
            MAP_ROWS)
    End Sub

    Friend Overrides Sub Initialize(map As IMap)
        For Each column In Enumerable.Range(0, map.Columns)
            For Each row In Enumerable.Range(0, map.Rows)
                Dim locationType = Business.LocationType.StartingRoomFloor
                If column = 0 OrElse row = 0 OrElse column = map.Columns - 1 OrElse row = map.Rows - 1 Then
                    locationType = Business.LocationType.GrayWall
                End If
                map.World.CreateLocation(map, column, row, locationType)
            Next
        Next
        Dim n00bDescriptor = CharacterType.N00b.ToCharacterTypeDescriptor
        Dim location = RNG.FromEnumerable(map.Locations.Where(Function(x) n00bDescriptor.CanSpawn(x)))
        map.World.Avatar = map.World.CreateCharacter(n00bDescriptor.CharacterType, location)
    End Sub
End Class
