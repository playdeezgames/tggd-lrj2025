Imports TGGD.UI

Public Class UIContext
    Implements IUIContext
    ReadOnly buffer As IUIBuffer(Of Integer)
    Private column As Integer
    Private row As Integer
    Private ReadOnly sfxQueue As New Queue(Of String)
    Sub New(columns As Integer, rows As Integer, pixelBuffer As Integer())
        Me.buffer = New UIBuffer(Of Integer)(columns, rows, pixelBuffer)
        column = columns \ 2
        row = rows \ 2
        buffer.SetPixel(column, row, Hue.White)
    End Sub

    Public ReadOnly Property Sfx As String Implements IUIContext.Sfx
        Get
            Return If(sfxQueue.Any, sfxQueue.Peek(), Nothing)
        End Get
    End Property

    Public Sub Refresh() Implements IUIContext.Refresh
        buffer.Fill(Hue.White)
        Fonts.GetFont(Font.CyFont4x6).Write(buffer, 1, 1, Hue.LightGray, "Hello, world!")
        Fonts.GetFont(Font.CyFont4x6).Write(buffer, 0, 0, Hue.Black, "Hello, world!")
        buffer.SetPixel(column, row, Hue.DarkGray)
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
            Case UI.Command.Green
                sfxQueue.Enqueue(UI.Sfx.PlayerHit)
        End Select
    End Sub

    Public Sub NextSfx() Implements IUIContext.NextSfx
        If sfxQueue.Any Then
            sfxQueue.Dequeue()
        End If
    End Sub
End Class
