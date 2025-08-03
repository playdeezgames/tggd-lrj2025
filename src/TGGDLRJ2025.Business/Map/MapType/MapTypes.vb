Imports System.Runtime.CompilerServices

Friend Module MapTypes
    Friend ReadOnly Descriptors As IReadOnlyDictionary(Of String, MapTypeDescriptor) =
        New List(Of MapTypeDescriptor) From
        {
            New BlueRoomMapTypeDescriptor()
        }.ToDictionary(Function(x) x.MapType, Function(x) x)
    <Extension>
    Friend Function ToMapTypeDescriptor(mapType As String) As MapTypeDescriptor
        Return Descriptors(mapType)
    End Function
End Module
