Imports System.Runtime.CompilerServices

Module ItemTypeDisplayProperties
    Private ReadOnly table As IReadOnlyDictionary(Of String, (Glyph As Char, Hue As Integer)) =
        New Dictionary(Of String, (Glyph As Char, Hue As Integer)) From
        {
            {Business.ItemType.Food, (Chr(7), Hue.DarkBlue)},
            {Business.ItemType.SilverKey, (Chr(5), Hue.LightGray)},
            {Business.ItemType.GoldKey, (Chr(5), Hue.Yellow)},
            {Business.ItemType.CarnelianKey, (Chr(5), Hue.Red)},
            {Business.ItemType.AmethystKey, (Chr(5), Hue.Magenta)},
            {Business.ItemType.SapphireKey, (Chr(5), Hue.Blue)},
            {Business.ItemType.RubyKey, (Chr(5), Hue.LightRed)},
            {Business.ItemType.EmeraldKey, (Chr(5), Hue.LightGreen)},
            {Business.ItemType.Sword, (Chr(9), Hue.LightBlue)},
            {Business.ItemType.Shield, (Chr(10), Hue.LightGreen)},
            {Business.ItemType.Potion, (Chr(11), Hue.Red)}
        }
    <Extension>
    Friend Function ToItemTypeDisplayProperties(itemType As String) As (Glyph As Char, Hue As Integer)
        Return table(itemType)
    End Function
End Module
