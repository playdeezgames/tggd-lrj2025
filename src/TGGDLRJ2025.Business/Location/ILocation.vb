Public Interface ILocation
    Inherits IEntity
    ReadOnly Property LocationType As String
    ReadOnly Property LocationId As Integer
    ReadOnly Property Map As IMap
    ReadOnly Property World As IWorld
    Property Character As ICharacter
    ReadOnly Property Column As Integer
    ReadOnly Property Row As Integer
    Function CanEnter(character As Character) As Boolean
    Sub Bump(character As Character)
End Interface
