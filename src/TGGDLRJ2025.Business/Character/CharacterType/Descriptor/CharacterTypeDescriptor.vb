Friend MustInherit Class CharacterTypeDescriptor
    Friend ReadOnly Property CharacterType As String
    Sub New(characterType As String)
        Me.CharacterType = characterType
    End Sub
    Friend MustOverride Sub Initialize(character As ICharacter)
    Friend MustOverride Function CanSpawn(location As ILocation) As Boolean
    Friend MustOverride Sub OnMove(character As ICharacter)
End Class
