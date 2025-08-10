Imports TGGDLRJ2025.Data

Public Class World
    Implements IWorld
    Private ReadOnly data As WorldData
    Private ReadOnly _playSfx As Action(Of String)

    Public Property Avatar As ICharacter Implements IWorld.Avatar
        Get
            Return If(data.AvatarId.HasValue, New Character(data, _playSfx, data.AvatarId.Value), Nothing)
        End Get
        Set(value As ICharacter)
            data.AvatarId = value?.CharacterId
        End Set
    End Property

    Public ReadOnly Property Maps As IEnumerable(Of IMap) Implements IWorld.Maps
        Get
            Return Enumerable.Range(0, data.Maps.Count).Select(Function(x) GetMap(x))
        End Get
    End Property

    Public ReadOnly Property HasMessages As Boolean Implements IWorld.HasMessages
        Get
            Return data.Messages.Any
        End Get
    End Property

    Public ReadOnly Property CurrentMessage As IMessage Implements IWorld.CurrentMessage
        Get
            If HasMessages Then
                Return New Message(data)
            End If
            Return Nothing
        End Get
    End Property

    Sub New(data As WorldData, playSfx As Action(Of String))
        Me.data = data
        Me._playSfx = playSfx
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
        Return New Map(data, _playSfx, mapId)
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
        Return New Location(data, _playSfx, locationId)
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
        Return New Character(data, _playSfx, characterId)
    End Function

    Public Sub Abandon() Implements IWorld.Abandon
        Clear()
    End Sub

    Public Sub AddMessage(lines As IEnumerable(Of (Mood As String, Text As String))) Implements IWorld.AddMessage
        data.Messages.Add(New MessageData With
                          {
                            .Lines = lines.Select(Function(x) New MessageLineData With
                                                      {
                                                        .Mood = x.Mood,
                                                        .Text = x.Text
                                                      }).ToList
                          })
    End Sub

    Public Sub DismissMessage() Implements IWorld.DismissMessage
        If HasMessages Then
            data.Messages.RemoveAt(0)
        End If
    End Sub

    Public Function CreateItem(itemType As String) As IItem Implements IWorld.CreateItem
        Dim itemId As Integer = data.Items.Count
        data.Items.Add(New ItemData With
                       {
                            .ItemType = itemType
                       })
        Dim item = GetItem(itemId)
        itemType.ToItemTypeDescriptor.Initialize(item)
        Return item
    End Function

    Public Function GetItem(itemId As Integer) As IItem Implements IWorld.GetItem
        Return New Item(data, _playSfx, itemId)
    End Function

    Public Sub PlaySfx(sfx As String) Implements IWorld.PlaySfx
        _playSfx(sfx)
    End Sub
End Class
