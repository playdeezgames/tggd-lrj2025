Public Interface ICharacter
    ReadOnly Property CharacterType As String
    ReadOnly Property CharacterId As Integer
    ReadOnly Property Location As ILocation
    ReadOnly Property Map As IMap
    ReadOnly Property World As IWorld
End Interface
