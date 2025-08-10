Public Interface IUIFont(Of TPixel)
    Function Write(
             buffer As IUIBuffer(Of Integer),
             column As Integer,
             row As Integer,
             hue As Integer,
             text As String) As Integer
    Sub WriteCentered(buffer As IUIBuffer(Of Integer),
             column As Integer,
             row As Integer,
             hue As Integer,
             text As String)
    Function GetTextWidth(text As String) As Integer
    ReadOnly Property Height As Integer
    ReadOnly Property Width As Integer
End Interface
