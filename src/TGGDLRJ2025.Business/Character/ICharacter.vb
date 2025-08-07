Public Interface ICharacter
    Inherits IEntity
    ReadOnly Property CharacterType As String
    ReadOnly Property CharacterId As Integer
    ReadOnly Property Location As ILocation
    ReadOnly Property Map As IMap
    ReadOnly Property World As IWorld
    Sub AttemptMove(directionType As String)
    Sub AddMessage(lines As IEnumerable(Of (Mood As String, Text As String)))
    ReadOnly Property IsAvatar As Boolean
End Interface
