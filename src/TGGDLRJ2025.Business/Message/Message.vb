Imports TGGDLRJ2025.Data

Friend Class Message
    Implements IMessage

    Private ReadOnly data As WorldData

    Public Sub New(data As WorldData)
        Me.data = data
    End Sub

    Public ReadOnly Property LineCount As Integer Implements IMessage.LineCount
        Get
            Return If(data.Messages.FirstOrDefault?.Lines?.Count, 0)
        End Get
    End Property

    Public ReadOnly Property Lines As IEnumerable(Of (Mood As String, Text As String)) Implements IMessage.Lines
        Get
            Return data.Messages.FirstOrDefault.Lines.Select(Function(x) (x.Mood, x.Text))
        End Get
    End Property
End Class
