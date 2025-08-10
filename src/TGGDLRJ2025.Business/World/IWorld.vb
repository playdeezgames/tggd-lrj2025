Public Interface IWorld
    Sub Initialize()
    Function CreateMap(mapType As String) As IMap
    Function GetMap(mapId As Integer) As IMap
    ReadOnly Property Maps As IEnumerable(Of IMap)
    Function CreateLocation(map As IMap, column As Integer, row As Integer, locationType As String) As ILocation
    Function GetLocation(locationId As Integer) As ILocation
    Function CreateCharacter(characterType As String, location As ILocation) As ICharacter
    Function GetCharacter(characterId As Integer) As ICharacter
    Sub Abandon()
    Sub AddMessage(lines As IEnumerable(Of (Mood As String, Text As String)))
    ReadOnly Property CurrentMessage As IMessage
    Sub DismissMessage()
    Property Avatar As ICharacter
    ReadOnly Property HasMessages As Boolean
    Function CreateItem(itemType As String) As IItem
    Function GetItem(itemId As Integer) As IItem
    Sub PlaySfx(sfx As String)
End Interface
