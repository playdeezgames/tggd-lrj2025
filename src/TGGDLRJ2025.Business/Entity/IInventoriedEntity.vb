Public Interface IInventoriedEntity
    Inherits IEntity
    Sub AddItem(item As IItem)
    ReadOnly Property Items As IEnumerable(Of IItem)
    Sub RemoveItem(item As IItem)
    Function GetItemTypeCount(itemType As String) As Integer
    Function GetItemOfType(itemType As String) As IItem
End Interface
