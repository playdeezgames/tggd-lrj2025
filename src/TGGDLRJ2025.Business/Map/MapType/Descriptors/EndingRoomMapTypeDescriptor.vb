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
            "#.#.........#.#",
            "#.#.#######.#.#",
            "#.#.#.....#.#.#",
            "#.#.#.###.#.#.#",
            "+.#.#.#.#.#.#.+",
            "#.#.#.###.#.#.#",
            "#.#.#.....#.#.#",
            "#.#.#######.#.#",
            "#.#.........#.#",
            "#.###########.#",
            "#.............#",
            "#######+#######"
        }

    Friend Overrides Sub Initialize(map As IMap)
        For Each column In Enumerable.Range(0, map.Columns)
            For Each row In Enumerable.Range(0, map.Rows)
                Dim locationType As String = Nothing
                Select Case terrainMap(row)(column)
                    Case "."c
                        locationType = EndingRoomFloor
                    Case "#"c
                        locationType = BlueWall
                    Case "+"c
                        locationType = Door
                    Case Else
                        Throw New NotImplementedException
                End Select
                map.World.CreateLocation(map, column, row, locationType)
            Next
        Next
    End Sub
End Class
