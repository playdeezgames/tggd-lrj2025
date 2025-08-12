Friend MustInherit Class CharacterTypeDescriptor
    Friend ReadOnly Property CharacterType As String
    Friend ReadOnly Property CharacterCount As Integer
    Sub New(characterType As String, characterCount As Integer)
        Me.CharacterType = characterType
        Me.CharacterCount = characterCount
    End Sub
    Friend MustOverride Sub Initialize(character As ICharacter)
    Friend MustOverride Function CanSpawn(location As ILocation) As Boolean
    Friend MustOverride Sub OnMove(character As ICharacter)
End Class
