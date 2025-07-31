Public Class UIContext
    Implements IUIContext
    ReadOnly columns As Integer
    ReadOnly rows As Integer
    ReadOnly buffer As Integer()
    Private column As Integer
    Private row As Integer
    Sub New(columns As Integer, rows As Integer, buffer As Integer())
        Me.columns = columns
        Me.rows = rows
        Me.buffer = buffer
        column = columns \ 2
        row = rows \ 2
        buffer(column + row * columns) = Hue.LightRed
    End Sub

    Public Sub Refresh() Implements IUIContext.Refresh
    End Sub

    Public Sub HandleCommand(command As String) Implements IUIContext.HandleCommand
        buffer(column + row * columns) = Hue.Black
        Select Case command
            Case UI.Command.Up
                row -= 1
            Case UI.Command.Down
                row += 1
            Case UI.Command.Left
                column -= 1
            Case UI.Command.RIGHT
                column += 1
        End Select
        buffer(column + row * columns) = Hue.LightRed
    End Sub
End Class
