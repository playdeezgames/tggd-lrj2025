Imports TGGDLRJ2025.Data

Public Class World
    Implements IWorld
    Private ReadOnly data As WorldData
    Sub New(data As WorldData)
        Me.data = data
    End Sub

    Public Sub Initialize() Implements IWorld.Initialize
        Clear()
        WorldInitializer.Initialize(Me)
    End Sub

    Public Function CreateMap(mapType As String) As IMap Implements IWorld.CreateMap
        Dim mapTypeDescriptor = mapType.ToMapTypeDescriptor
        Dim mapId = data.Maps.Count
        Dim mapData = New MapData With
            {
                .MapType = mapType,
                .Columns = mapTypeDescriptor.Columns,
                .Rows = mapTypeDescriptor.Rows,
                .Locations = Enumerable.Range(0, mapTypeDescriptor.Columns * mapTypeDescriptor.Rows).
                    Select(Function(x) New LocationData With
                        {
                            .LocationType = Nothing,
                            .Column = x Mod mapTypeDescriptor.Columns,
                            .Row = x \ mapTypeDescriptor.Rows
                        }).ToList
            }
        data.Maps.Add(mapData)
        Dim map = GetMap(mapId)
        mapTypeDescriptor.Initialize(map)
        Return map
    End Function

    Private Sub Clear()
        data.Maps.Clear()
    End Sub

    Public Function GetMap(mapId As Integer) As IMap Implements IWorld.GetMap
        Return New Map(data, mapId)
    End Function
End Class
