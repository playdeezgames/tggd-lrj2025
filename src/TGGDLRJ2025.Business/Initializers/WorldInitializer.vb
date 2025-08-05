Friend Module WorldInitializer
    Friend Sub Initialize(world As IWorld)
        For Each mapType In MapTypes.All
            Dim descriptor = mapType.ToMapTypeDescriptor
            For Each index In Enumerable.Range(0, descriptor.Count)
                world.CreateMap(mapType)
            Next
        Next
        Dim startMap = world.Maps.Single(Function(x) x.MapType = MapType.StartingRoom)
        Dim endMap = world.Maps.Single(Function(x) x.MapType = MapType.EndingRoom)

        LinkMaps(startMap, endMap, DirectionType.North)
        LinkMaps(startMap, startMap, DirectionType.East)
        LinkMaps(startMap, startMap, DirectionType.South)
        LinkMaps(startMap, startMap, DirectionType.West)

        LinkMaps(endMap, startMap, DirectionType.North)
        LinkMaps(endMap, startMap, DirectionType.East)
        LinkMaps(endMap, startMap, DirectionType.South)
        LinkMaps(endMap, startMap, DirectionType.West)
    End Sub

    Private Sub LinkMaps(fromMap As IMap, toMap As IMap, directionType As String)
        Dim fromDoorLocation = directionType.ToDirectionTypeDescriptor.GetDoorFromLocation(fromMap)
        Dim fromLocation = fromMap.GetLocation(fromDoorLocation.Column, fromDoorLocation.Row)
        Dim toDoorLocation = directionType.ToDirectionTypeDescriptor.GetDoorToLocation(toMap)
        Dim toLocation = toMap.GetLocation(toDoorLocation.Column, toDoorLocation.Row)
        fromLocation.SetStatistic(StatisticType.DestinationLocationId, toLocation.LocationId)
    End Sub
End Module
