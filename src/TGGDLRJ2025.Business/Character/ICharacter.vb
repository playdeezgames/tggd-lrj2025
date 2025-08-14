Public Interface ICharacter
    Inherits IInventoriedEntity
    ReadOnly Property CharacterType As String
    ReadOnly Property CharacterId As Integer
    ReadOnly Property Location As ILocation
    ReadOnly Property Map As IMap
    ReadOnly Property World As IWorld
    Sub AttemptMove(directionType As String)
    Sub AddMessage(sfx As String, lines As IEnumerable(Of (Mood As String, Text As String)))
    ReadOnly Property IsAvatar As Boolean
    ReadOnly Property IsDead As Boolean
    Sub UseItem(item As IItem)
    Sub Interact(otherCharacter As ICharacter, isCounter As Boolean)
    ReadOnly Property Name As String
End Interface
