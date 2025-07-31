Public Class UIContext
    Implements IUIContext
    ReadOnly columns As Integer
    ReadOnly rows As Integer
    ReadOnly buffer As Integer()
    Sub New(columns As Integer, rows As Integer, buffer As Integer())
        Me.columns = columns
        Me.rows = rows
        Me.buffer = buffer
    End Sub

    Public Sub Refresh() Implements IUIContext.Refresh
        For Each column In Enumerable.Range(0, columns)
            buffer(column + column * rows) = 15
        Next
    End Sub
End Class
