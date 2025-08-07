Friend Class EndingRoomMapTypeDescriptor
    Inherits MapTypeDescriptor
    Const MAP_COUNT = 1
    Const MAP_COLUMNS = 15
    Const MAP_ROWS = 15

    Public Sub New()
        MyBase.New(
            Business.MapType.EndingRoom,
            MAP_COUNT,
            MAP_COLUMNS,
            MAP_ROWS)
    End Sub

    Private ReadOnly terrainMap As IReadOnlyList(Of String) =
        New List(Of String) From
        {
            "#######+#######",
            "#.............#",
            "#.###########.#",
            "#.#....3....#.#",
            "#.#.#######.#.#",
            "#.#.#..5..#.#.#",
            "#.#.#.###.#.#.#",
            "+.#2#6#!#.4.#.+",
            "#.#.#.#7#.###.#",
            "#.#.#...#.#.#.#",
            "#.#.#######.#.#",
            "#.#.........#.#",
            "#.#####1#####.#",
            "#.............#",
            "#######+#######"
        }

    Private ReadOnly terrainTable As IReadOnlyDictionary(Of Char, String) =
        New Dictionary(Of Char, String) From
        {
            {"."c, EndingRoomFloor},
            {"#"c, BlueWall},
            {"+"c, Door},
            {"1"c, SilverDoor},
            {"2"c, GoldDoor},
            {"3"c, CarnelianDoor},
            {"4"c, AmethystDoor},
            {"5"c, SapphireDoor},
            {"6"c, RubyDoor},
            {"7"c, EmeraldDoor},
            {"!"c, DiamondDoor}
        }

    Friend Overrides Sub Initialize(map As IMap)
        For Each column In Enumerable.Range(0, map.Columns)
            For Each row In Enumerable.Range(0, map.Rows)
                Dim locationType As String = terrainTable(terrainMap(row)(column))
                map.World.CreateLocation(map, column, row, locationType)
            Next
        Next
    End Sub
End Class
