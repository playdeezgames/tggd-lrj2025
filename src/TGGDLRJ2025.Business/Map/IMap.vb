Public Interface IMap
    Inherits IEntity
    ReadOnly Property MapId As Integer
    ReadOnly Property Columns As Integer
    ReadOnly Property Rows As Integer
    ReadOnly Property MapType As String
    Function GetLocation(column As Integer, row As Integer) As ILocation
    ReadOnly Property World As IWorld
    ReadOnly Property Locations As IEnumerable(Of ILocation)
End Interface
