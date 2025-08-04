Public Interface IWorld
    Sub Initialize()
    Function CreateMap(mapType As String) As IMap
    Function GetMap(mapId As Integer) As IMap
    Function CreateLocation(map As IMap, column As Integer, row As Integer, locationType As String) As ILocation
    Function GetLocation(locationId As Integer) As ILocation
    Function CreateCharacter(characterType As String, location As ILocation) As ICharacter
    Function GetCharacter(characterId As Integer) As ICharacter
    Sub Abandon()
    Property Avatar As ICharacter
End Interface
