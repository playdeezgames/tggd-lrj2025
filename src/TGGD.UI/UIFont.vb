Public Class UIFont(Of TPixel)
    Implements IUIFont(Of TPixel)

    Private ReadOnly FontData As FontData

    Sub New(fontData As FontData)
        Me.FontData = fontData
    End Sub

    Public ReadOnly Property Height As Integer Implements IUIFont(Of TPixel).Height
        Get
            Return FontData.Height
        End Get
    End Property

    Public ReadOnly Property Width As Integer Implements IUIFont(Of TPixel).Width
        Get
            Return FontData.Glyphs.First.Value.Width
        End Get
    End Property

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

    Public Sub WriteCentered(buffer As IUIBuffer(Of Integer), column As Integer, row As Integer, hue As Integer, text As String) Implements IUIFont(Of TPixel).WriteCentered
        Write(buffer, column - GetTextWidth(text) \ 2, row, hue, text)
    End Sub

    Public Function GetTextWidth(text As String) As Integer Implements IUIFont(Of TPixel).GetTextWidth
        Dim result As Integer = 0
        For Each character In text
            result += FontData.Glyphs(character).Width
        Next
        Return result
    End Function

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
