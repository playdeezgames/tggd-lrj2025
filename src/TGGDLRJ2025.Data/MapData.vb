Public Class MapData
    Inherits EntityData
    Public Property MapType As String
    Public Property Rows As Integer
    Public Property Columns As Integer
    Public Property Locations As New List(Of Integer?)
End Class
