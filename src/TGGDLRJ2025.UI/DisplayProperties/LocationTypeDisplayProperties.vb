Imports System.Runtime.CompilerServices

Friend Module LocationTypeDisplayProperties
    Private ReadOnly table As IReadOnlyDictionary(Of String, (Glyph As Char, Hue As Integer)) =
        New Dictionary(Of String, (Glyph As Char, Hue As Integer)) From
        {
            {Business.LocationType.Floor, (Chr(3), Hue.DarkerGray)},
            {Business.LocationType.BlueWall, (Chr(2), Hue.Blue)}
        }
    <Extension>
    Friend Function ToLocationTypeDisplayProperties(locationType As String) As (Glyph As Char, Hue As Integer)
        Return table(locationType)
    End Function
End Module
