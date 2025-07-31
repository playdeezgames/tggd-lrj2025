Public Interface IUIFont(Of TPixel)
    Sub Write(
             buffer As IUIBuffer(Of Integer),
             column As Integer,
             row As Integer,
             hue As Integer,
             text As String)
End Interface
