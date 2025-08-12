Imports System.Runtime.CompilerServices

Friend Module CharacterTypeDisplayProperties
    Private ReadOnly table As IReadOnlyDictionary(Of String, (Glyph As Char, Hue As Integer)) =
        New Dictionary(Of String, (Glyph As Char, Hue As Integer)) From
        {
            {Business.CharacterType.N00b, (Chr(1), Hue.Brown)},
            {Business.CharacterType.MoonPerson, (Chr(8), Hue.DarkGray)}
        }
    <Extension>
    Friend Function ToCharacterTypeDisplayProperties(characterType As String) As (Glyph As Char, Hue As Integer)
        Return table(characterType)
    End Function
End Module
