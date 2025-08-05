Imports System.Runtime.CompilerServices

Friend Module MapTypes
    Private ReadOnly Descriptors As IReadOnlyDictionary(Of String, MapTypeDescriptor) =
        New List(Of MapTypeDescriptor) From
        {
            New BlueRoomMapTypeDescriptor()
        }.ToDictionary(Function(x) x.MapType, Function(x) x)
    <Extension>
    Friend Function ToMapTypeDescriptor(mapType As String) As MapTypeDescriptor
        Return Descriptors(mapType)
    End Function
    Friend ReadOnly Property All As IEnumerable(Of String)
        Get
            Return Descriptors.Keys
        End Get
    End Property
End Module
