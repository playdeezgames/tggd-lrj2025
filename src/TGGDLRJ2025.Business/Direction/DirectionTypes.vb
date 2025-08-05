Imports System.Runtime.CompilerServices

Friend Module DirectionTypes
    Private ReadOnly Descriptors As IReadOnlyDictionary(Of String, DirectionTypeDescriptor) =
        New List(Of DirectionTypeDescriptor) From
        {
            New NorthDirectionTypeDescriptor(),
            New EastDirectionTypeDescriptor(),
            New SouthDirectionTypeDescriptor(),
            New WestDirectionTypeDescriptor()
        }.ToDictionary(Function(x) x.DirectionType, Function(x) x)
    <Extension>
    Friend Function ToDirectionTypeDescriptor(directionType As String) As DirectionTypeDescriptor
        Return Descriptors(directionType)
    End Function
    Friend ReadOnly Property All As IEnumerable(Of String)
        Get
            Return Descriptors.Keys
        End Get
    End Property
End Module
