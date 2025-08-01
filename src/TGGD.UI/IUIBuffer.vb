Public Interface IUIBuffer(Of TPixel)
    Sub SetPixel(column As Integer, row As Integer, hue As TPixel)
    Sub Fill(column As Integer, row As Integer, columns As Integer, rows As Integer, hue As TPixel)
    Sub Fill(hue As TPixel)
    ReadOnly Property Columns As Integer
    ReadOnly Property Rows As Integer
End Interface
