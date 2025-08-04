Friend Class N00bCharacterTypeDescriptor
    Inherits CharacterTypeDescriptor

    Public Sub New()
        MyBase.New(Business.CharacterType.N00b)
    End Sub

    Friend Overrides Sub Initialize(character As ICharacter)
    End Sub
End Class
