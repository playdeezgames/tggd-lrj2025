Imports System.Runtime.CompilerServices

Friend Module DirectionTypes
    Private ReadOnly Descriptors As IReadOnlyDictionary(Of String, DirectionTypeDescriptor) =
        New List(Of DirectionTypeDescriptor) From
        {
            New DirectionTypeDescriptor(DirectionType.North, 0, -1),
            New DirectionTypeDescriptor(DirectionType.East, 1, 0),
            New DirectionTypeDescriptor(DirectionType.South, 0, 1),
            New DirectionTypeDescriptor(DirectionType.West, -1, 0)
        }.ToDictionary(Function(x) x.DirectionType, Function(x) x)
    <Extension>
    Friend Function ToDirectionTypeDescriptor(directionType As String) As DirectionTypeDescriptor
        Return Descriptors(directionType)
    End Function
End Module
