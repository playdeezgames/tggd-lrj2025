Friend MustInherit Class MapTypeDescriptor
    Friend ReadOnly MapType As String
    Friend ReadOnly Columns As Integer
    Friend ReadOnly Rows As Integer
    Sub New(
           mapType As String,
           columns As Integer,
           rows As Integer)
        Me.MapType = mapType
        Me.Columns = columns
        Me.Rows = rows
    End Sub
    Friend MustOverride Sub Initialize(map As IMap)
End Class
