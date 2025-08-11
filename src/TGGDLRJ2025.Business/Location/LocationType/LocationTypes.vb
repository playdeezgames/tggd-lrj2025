Imports System.Runtime.CompilerServices

Friend Module LocationTypes
    Friend ReadOnly Descriptors As IReadOnlyDictionary(Of String, LocationTypeDescriptor) =
        New List(Of LocationTypeDescriptor) From
        {
            New StartingFloorLocationTypeDescriptor(),
            New FloorLocationTypeDescriptor(),
            New EndingFloorLocationTypeDescriptor(),
            New BlueWallLocationTypeDescriptor(),
            New GrayWallLocationTypeDescriptor(),
            New DoorLocationTypeDescriptor(),
            New SilverDoorLocationTypeDescriptor(),
            New GoldDoorLocationTypeDescriptor(),
            New CarneliianDoorLocationTypeDescriptor(),
            New AmethystDoorLocationTypeDescriptor(),
            New SapphireDoorLocationTypeDescriptor(),
            New RubyDoorLocationTypeDescriptor(),
            New EmeraldDoorLocationTypeDescriptor(),
            New FinalSignLocationTypeDescriptor(),
            New SignLocationTypeDescriptor()
    }.ToDictionary(Function(x) x.LocationType, Function(x) x)
    <Extension>
    Friend Function ToLocationTypeDescriptor(locationType As String) As LocationTypeDescriptor
        Return Descriptors(locationType)
    End Function
End Module
