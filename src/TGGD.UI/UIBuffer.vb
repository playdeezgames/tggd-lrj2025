Public Class UIBuffer(Of TPixel)
    Implements IUIBuffer(Of TPixel)

    Private ReadOnly columns As Integer
    Private ReadOnly rows As Integer
    Private ReadOnly pixelBuffer As TPixel()

    Sub New(columns As Integer, rows As Integer, pixelBuffer As TPixel())
        Me.columns = columns
        Me.rows = rows
        Me.pixelBuffer = pixelBuffer
    End Sub

    Public Sub SetPixel(column As Integer, row As Integer, hue As TPixel) Implements IUIBuffer(Of TPixel).SetPixel
        If column >= 0 AndAlso column < columns AndAlso row >= 0 AndAlso row < rows Then
            pixelBuffer(column + row * columns) = hue
        End If
    End Sub
End Class
