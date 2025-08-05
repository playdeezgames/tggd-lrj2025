Imports System.Runtime.CompilerServices

Friend Module LocationTypes
    Friend ReadOnly Descriptors As IReadOnlyDictionary(Of String, LocationTypeDescriptor) =
        New List(Of LocationTypeDescriptor) From
        {
            New StartingFloorLocationTypeDescriptor(),
            New EndingFloorLocationTypeDescriptor(),
            New BlueWallLocationTypeDescriptor(),
            New GrayWallLocationTypeDescriptor(),
            New DoorLocationTypeDescriptor()
    }.ToDictionary(Function(x) x.LocationType, Function(x) x)
    <Extension>
    Friend Function ToLocationTypeDescriptor(locationType As String) As LocationTypeDescriptor
        Return Descriptors(locationType)
    End Function
End Module
