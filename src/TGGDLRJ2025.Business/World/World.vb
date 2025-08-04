Imports TGGDLRJ2025.Data

Public Class World
    Implements IWorld
    Private ReadOnly data As WorldData

    Public Property Avatar As ICharacter Implements IWorld.Avatar
        Get
            Return If(data.AvatarId.HasValue, New Character(data, data.AvatarId.Value), Nothing)
        End Get
        Set(value As ICharacter)
            data.AvatarId = value?.CharacterId
        End Set
    End Property

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
        data.Maps.Add(New MapData With
            {
                .MapType = mapType,
                .Columns = mapTypeDescriptor.Columns,
                .Rows = mapTypeDescriptor.Rows,
                .Locations = Enumerable.Range(0, mapTypeDescriptor.Columns * mapTypeDescriptor.Rows).
                    Select(Function(x) CType(Nothing, Integer?)).ToList
            })
        Dim map = GetMap(mapId)
        mapTypeDescriptor.Initialize(map)
        Return map
    End Function

    Private Sub Clear()
        data.Maps.Clear()
        data.Characters.Clear()
        data.Locations.Clear()
        data.AvatarId = Nothing
    End Sub

    Public Function GetMap(mapId As Integer) As IMap Implements IWorld.GetMap
        Return New Map(data, mapId)
    End Function

    Public Function CreateLocation(map As IMap, column As Integer, row As Integer, locationType As String) As ILocation Implements IWorld.CreateLocation
        Dim locationTypeDescriptor = locationType.ToLocationTypeDescriptor
        Dim locationId = data.Locations.Count
        data.Locations.Add(New LocationData With {
                           .LocationType = locationType,
                           .MapId = map.MapId,
                           .Column = column,
                           .Row = row})
        Dim location = GetLocation(locationId)
        data.Maps(map.MapId).Locations(column + row * map.Columns) = location.LocationId
        locationTypeDescriptor.Initialize(location)
        Return location
    End Function

    Public Function GetLocation(locationId As Integer) As ILocation Implements IWorld.GetLocation
        Return New Location(data, locationId)
    End Function

    Public Function CreateCharacter(characterType As String, location As ILocation) As ICharacter Implements IWorld.CreateCharacter
        Dim characterTypeDescriptor = characterType.ToCharacterTypeDescriptor
        Dim characterId = data.Characters.Count
        data.Characters.Add(New CharacterData With
                            {
                                .CharacterType = characterType,
                                .LocationId = location.LocationId
                            })
        data.Locations(location.LocationId).CharacterId = characterId
        Dim character = GetCharacter(characterId)
        characterTypeDescriptor.Initialize(character)
        Return character
    End Function

    Public Function GetCharacter(characterId As Integer) As ICharacter Implements IWorld.GetCharacter
        Return New Character(data, characterId)
    End Function

    Public Sub Abandon() Implements IWorld.Abandon
        Clear()
    End Sub
End Class
