Public Interface IWorld
    Sub Initialize()
    Function CreateMap(mapType As String) As IMap
    Function GetMap(mapId As Integer) As IMap
    Function CreateLocation(map As IMap, column As Integer, row As Integer, locationType As String) As ILocation
    Function GetLocation(locationId As Integer) As ILocation
End Interface
