Public Interface IItem
    Inherits IEntity
    ReadOnly Property ItemId As Integer
    ReadOnly Property ItemType As String
    ReadOnly Property PickUpSfx As String
End Interface
