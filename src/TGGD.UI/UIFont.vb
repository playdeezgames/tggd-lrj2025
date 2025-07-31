Public Class UIFont(Of TPixel)
    Implements IUIFont(Of TPixel)

    Private ReadOnly FontData As FontData

    Sub New(fontData As FontData)
        Me.FontData = fontData
    End Sub

    Public Sub Write(
                    buffer As IUIBuffer(Of Integer),
                    column As Integer,
                    row As Integer,
                    hue As Integer,
                    text As String) Implements IUIFont(Of TPixel).Write
        For Each character In text
            column = WriteGlyph(buffer, column, row, hue, character)
        Next
    End Sub

    Private Function WriteGlyph(
                               buffer As IUIBuffer(Of Integer),
                               column As Integer,
                               row As Integer,
                               hue As Integer,
                               character As Char) As Integer
        Dim glyphData = FontData.Glyphs(character)
        For Each line In glyphData.Lines
            For Each x In line.Value
                buffer.SetPixel(column + x, row + line.Key, hue)
            Next
        Next
        Return column + glyphData.Width
    End Function
End Class
