Public Interface IMessage
    ReadOnly Property LineCount As Integer
    ReadOnly Property Lines As IEnumerable(Of (Mood As String, Text As String))
End Interface
