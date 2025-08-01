Public Interface IUIFont(Of TPixel)
    Sub Write(
             buffer As IUIBuffer(Of Integer),
             column As Integer,
             row As Integer,
             hue As Integer,
             text As String)
    Sub WriteCentered(buffer As IUIBuffer(Of Integer),
             column As Integer,
             row As Integer,
             hue As Integer,
             text As String)
    Function GetWidth(text As String) As Integer
    ReadOnly Property Height As Integer
End Interface
