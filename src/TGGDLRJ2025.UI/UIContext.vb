Imports TGGD.UI

Public Class UIContext
    Implements IUIContext
    ReadOnly buffer As IUIBuffer(Of Integer)
    Private column As Integer
    Private row As Integer
    Sub New(columns As Integer, rows As Integer, pixelBuffer As Integer())
        Me.buffer = New UIBuffer(Of Integer)(columns, rows, pixelBuffer)
        column = columns \ 2
        row = rows \ 2
        buffer.SetPixel(column, row, Hue.White)
    End Sub

    Public Sub Refresh() Implements IUIContext.Refresh
    End Sub

    Public Sub HandleCommand(command As String) Implements IUIContext.HandleCommand
        buffer.SetPixel(column, row, Hue.Black)
        Select Case command
            Case UI.Command.Up
                row -= 1
            Case UI.Command.Down
                row += 1
            Case UI.Command.Left
                column -= 1
            Case UI.Command.Right
                column += 1
        End Select
        buffer.SetPixel(column, row, Hue.White)
    End Sub
End Class
