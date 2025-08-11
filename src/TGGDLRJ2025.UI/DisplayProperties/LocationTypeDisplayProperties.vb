Imports System.Runtime.CompilerServices

Friend Module LocationTypeDisplayProperties
    Private ReadOnly table As IReadOnlyDictionary(Of String, (Glyph As Char, Hue As Integer)) =
        New Dictionary(Of String, (Glyph As Char, Hue As Integer)) From
        {
            {Business.LocationType.StartingRoomFloor, (Chr(3), Hue.DarkerGray)},
            {Business.LocationType.RoomFloor, (Chr(3), Hue.DarkerGray)},
            {Business.LocationType.BlueWall, (Chr(2), Hue.Blue)},
            {Business.LocationType.EndingRoomFloor, (Chr(3), Hue.DarkerGray)},
            {Business.LocationType.GrayWall, (Chr(2), Hue.DarkGray)},
            {Business.LocationType.Door, (Chr(4), Hue.Brown)},
            {Business.LocationType.SilverDoor, (Chr(4), Hue.LightGray)},
            {Business.LocationType.GoldDoor, (Chr(4), Hue.Yellow)},
            {Business.LocationType.CarnelianDoor, (Chr(4), Hue.Red)},
            {Business.LocationType.AmethystDoor, (Chr(4), Hue.Magenta)},
            {Business.LocationType.SapphireDoor, (Chr(4), Hue.Blue)},
            {Business.LocationType.RubyDoor, (Chr(4), Hue.LightRed)},
            {Business.LocationType.EmeraldDoor, (Chr(4), Hue.LightGreen)},
            {Business.LocationType.FinalSign, (Chr(6), Hue.Brown)},
            {Business.LocationType.Sign, (Chr(6), Hue.Brown)}
        }
    <Extension>
    Friend Function ToLocationTypeDisplayProperties(locationType As String) As (Glyph As Char, Hue As Integer)
        Return table(locationType)
    End Function
End Module
