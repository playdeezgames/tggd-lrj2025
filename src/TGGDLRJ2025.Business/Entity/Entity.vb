Imports TGGDLRJ2025.Data

Public MustInherit Class Entity
    Implements IEntity
    Protected ReadOnly data As WorldData
    Sub New(data As WorldData)
        Me.data = data
    End Sub
End Class
