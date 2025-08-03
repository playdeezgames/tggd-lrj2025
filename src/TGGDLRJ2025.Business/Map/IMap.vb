Public Interface IMap
    ReadOnly Property MapId As Integer
    ReadOnly Property Columns As Integer
    ReadOnly Property Rows As Integer
    Function GetLocation(column As Integer, row As Integer) As ILocation
    ReadOnly Property World As IWorld
End Interface
