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
        Dim fromLocation = startMap.GetLocation(startMap.Columns \ 2, 0)
        Dim toLocation = endMap.GetLocation(endMap.Columns \ 2, endMap.Rows - 2)
        fromLocation.SetStatistic(StatisticType.DestinationLocationId, toLocation.LocationId)
    End Sub
End Module
