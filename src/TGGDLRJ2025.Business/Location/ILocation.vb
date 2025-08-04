Public Interface ILocation
    ReadOnly Property LocationType As String
    ReadOnly Property LocationId As Integer
    ReadOnly Property Map As IMap
    ReadOnly Property World As IWorld
End Interface
