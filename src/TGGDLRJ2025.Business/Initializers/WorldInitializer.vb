Imports TGGD.Business

Friend Module WorldInitializer
    Friend Sub Initialize(world As IWorld)
        For Each mapType In MapTypes.All
            Dim descriptor = mapType.ToMapTypeDescriptor
            For Each index In Enumerable.Range(0, descriptor.Count)
                world.CreateMap(mapType)
            Next
        Next

        Dim rooms As New List(Of IMap) From {
            world.Maps.Single(Function(x) x.MapType = MapType.StartingRoom)
        }
        rooms.AddRange(world.Maps.Where(Function(x) x.MapType = MapType.Room))
        rooms.Add(world.Maps.Single(Function(x) x.MapType = MapType.EndingRoom))
        Dim roomDirections = rooms.Select(Function(x) New HashSet(Of String)).ToList

        Dim path As New List(Of String)
        For Each roomIndex In Enumerable.Range(0, rooms.Count - 1)
            Dim room = rooms(roomIndex)
            room.GetLocation(room.Columns \ 2, room.Rows \ 2).SetStatistic(StatisticType.RoomNumber, roomIndex + 1)
            Dim nextRoomIndex = roomIndex + 1
            Dim nextRoom = rooms(nextRoomIndex)
            Dim direction As String = Nothing
            Do
                direction = RNG.FromEnumerable(DirectionTypes.All)
            Loop Until Not roomDirections(roomIndex).Contains(direction)
            path.Add(direction)
            Dim oppositeDirection = direction.ToDirectionTypeDescriptor.OppositeDirectionType
            roomDirections(roomIndex).Add(direction)
            roomDirections(nextRoomIndex).Add(oppositeDirection)
            LinkMaps(room, nextRoom, direction)
            LinkMaps(nextRoom, room, oppositeDirection)
        Next
        For Each roomIndex In Enumerable.Range(0, rooms.Count)
            Dim room = rooms(roomIndex)
            For Each direction In DirectionTypes.All
                If roomDirections(roomIndex).Contains(direction) Then
                    Continue For
                End If
                roomDirections(roomIndex).Add(direction)
                Dim oppositeDirection = direction.ToDirectionTypeDescriptor.OppositeDirectionType
                Dim candidates = Enumerable.Range(0, rooms.Count).Where(Function(index) Not roomDirections(index).Contains(oppositeDirection))
                Dim nextRoomIndex = RNG.FromEnumerable(candidates)
                Dim nextRoom = rooms(nextRoomIndex)
                roomDirections(nextRoomIndex).Add(oppositeDirection)
                LinkMaps(room, nextRoom, direction)
                LinkMaps(nextRoom, room, oppositeDirection)
            Next
        Next
    End Sub

    Private Sub LinkMaps(fromMap As IMap, toMap As IMap, directionType As String)
        Dim fromDoorLocation = directionType.ToDirectionTypeDescriptor.GetDoorFromLocation(fromMap)
        Dim fromLocation = fromMap.GetLocation(fromDoorLocation.Column, fromDoorLocation.Row)
        Dim toDoorLocation = directionType.ToDirectionTypeDescriptor.GetDoorToLocation(toMap)
        Dim toLocation = toMap.GetLocation(toDoorLocation.Column, toDoorLocation.Row)
        fromLocation.SetStatistic(StatisticType.DestinationLocationId, toLocation.LocationId)
    End Sub
End Module
