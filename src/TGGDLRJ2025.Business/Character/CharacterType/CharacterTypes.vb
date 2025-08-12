Imports System.Runtime.CompilerServices

Friend Module CharacterTypes
    Private ReadOnly Descriptors As IReadOnlyDictionary(Of String, CharacterTypeDescriptor) =
        New List(Of CharacterTypeDescriptor) From
        {
            New N00bCharacterTypeDescriptor(),
            New MoonPersonCharacterTypeDescriptor()
        }.ToDictionary(Function(x) x.CharacterType, Function(x) x)
    <Extension>
    Friend Function ToCharacterTypeDescriptor(characterType As String) As CharacterTypeDescriptor
        Return Descriptors(characterType)
    End Function
    Friend ReadOnly Property All As IEnumerable(Of String)
        Get
            Return Descriptors.Keys
        End Get
    End Property
End Module
