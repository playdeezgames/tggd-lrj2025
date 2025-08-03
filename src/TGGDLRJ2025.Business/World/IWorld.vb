Public Interface IWorld
    Sub Initialize()
    Function CreateMap(mapType As String) As IMap
    Function GetMap(mapId As Integer) As IMap
End Interface
