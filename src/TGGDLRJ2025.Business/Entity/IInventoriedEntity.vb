Public Interface IInventoriedEntity
    Inherits IEntity
    Sub AddItem(item As IItem)
    ReadOnly Property Items As IEnumerable(Of IItem)
    Sub RemoveItem(item As IItem)
End Interface
