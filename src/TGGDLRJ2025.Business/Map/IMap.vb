Public Interface IMap
    ReadOnly Property Id As Integer
    ReadOnly Property Columns As Integer
    ReadOnly Property Rows As Integer
    Function GetLocation(column As Integer, row As Integer) As ILocation
End Interface
