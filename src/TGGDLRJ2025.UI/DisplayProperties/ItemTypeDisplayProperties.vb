Imports System.Runtime.CompilerServices

Module ItemTypeDisplayProperties
    Private ReadOnly table As IReadOnlyDictionary(Of String, (Glyph As Char, Hue As Integer)) =
        New Dictionary(Of String, (Glyph As Char, Hue As Integer)) From
        {
            {Business.ItemType.Food, (Chr(7), Hue.LightRed)},
            {Business.ItemType.SilverKey, (Chr(7), Hue.LightGray)},
            {Business.ItemType.GoldKey, (Chr(7), Hue.Yellow)},
            {Business.ItemType.CarnelianKey, (Chr(7), Hue.Red)},
            {Business.ItemType.AmethystKey, (Chr(7), Hue.Magenta)},
            {Business.ItemType.SapphireKey, (Chr(7), Hue.Blue)},
            {Business.ItemType.RubyKey, (Chr(7), Hue.LightRed)},
            {Business.ItemType.EmeraldKey, (Chr(7), Hue.LightGreen)}
        }
    <Extension>
    Friend Function ToItemTypeDisplayProperties(itemType As String) As (Glyph As Char, Hue As Integer)
        Return table(itemType)
    End Function
End Module
