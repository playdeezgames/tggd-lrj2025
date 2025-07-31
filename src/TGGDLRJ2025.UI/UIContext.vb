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
        buffer.Fill(Hue.Blue)
        Fonts.GetFont(Font.CyFont4x6).Write(buffer, 1, 1, Hue.Black, "Hello, world!")
        Fonts.GetFont(Font.CyFont4x6).Write(buffer, 0, 0, Hue.White, "Hello, world!")
        buffer.SetPixel(column, row, Hue.Red)
    End Sub

    Public Sub HandleCommand(command As String) Implements IUIContext.HandleCommand
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
    End Sub
End Class
