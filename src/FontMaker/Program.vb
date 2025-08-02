Imports System.Drawing
Imports System.IO
Imports System.Text.Json
Imports TGGD.UI

Module Program
    Const InputFilename = "source.png"
    Const CellWidth = 10
    Const CellHeight = 10
    Sub Main(args As String())
        Dim bmp = New Bitmap(InputFilename)
        Dim rows = (bmp.Height + 1) \ (CellHeight + 1)
        Dim columns = (bmp.Width + 1) \ (CellWidth + 1)
        Dim glyph = ChrW(0)
        Dim fontData As New FontData With {
            .Height = CellHeight,
            .Glyphs = New Dictionary(Of Char, GlyphData)
        }
        For row = 0 To rows - 1
            For column = 0 To columns - 1
                Dim glyphData As New GlyphData With {.Width = CellWidth, .Lines = New Dictionary(Of Integer, IEnumerable(Of Integer))}
                fontData.Glyphs(glyph) = glyphData
                glyph = ChrW(AscW(glyph) + 1)
                Console.WriteLine(AscW(glyph))
                For y = 0 To CellHeight - 1
                    Dim line As New List(Of Integer)
                    For x = 0 To CellWidth - 1
                        Dim color = bmp.GetPixel(column * (CellWidth + 1) + x, row * (CellHeight + 1) + y)
                        If color.R = 0 AndAlso color.G = 0 AndAlso color.B = 0 Then
                            Console.Write(" ")
                        Else
                            Console.Write("#")
                            line.Add(x)
                        End If
                    Next
                    If line.Any Then
                        glyphData.Lines(y) = line
                    End If
                    Console.WriteLine()
                Next
            Next
        Next
        File.WriteAllText(Path.GetFullPath("output.json"), JsonSerializer.Serialize(fontData).Replace("""", """"""))
    End Sub
End Module
