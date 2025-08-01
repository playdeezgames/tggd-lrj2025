Imports TGGDLRJ2025.Data

Public Class World
    Implements IWorld
    Private ReadOnly data As WorldData
    Sub New(data As WorldData)
        Me.data = data
    End Sub
End Class
