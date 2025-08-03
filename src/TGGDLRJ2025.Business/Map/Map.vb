Imports TGGDLRJ2025.Data

Public Class Map
    Implements IMap
    Private ReadOnly data As WorldData
    Private ReadOnly Property MapData As MapData
        Get
            Return data.Maps(Id)
        End Get
    End Property
    Sub New(data As WorldData, id As Integer)
        Me.data = data
        Me.Id = id
    End Sub
    Public ReadOnly Property Id As Integer Implements IMap.Id

    Public ReadOnly Property Columns As Integer Implements IMap.Columns
        Get
            Return MapData.Columns
        End Get
    End Property

    Public ReadOnly Property Rows As Integer Implements IMap.Rows
        Get
            Return MapData.Rows
        End Get
    End Property

    Public Function GetLocation(column As Integer, row As Integer) As ILocation Implements IMap.GetLocation
        If column >= 0 AndAlso column < Columns AndAlso row >= 0 AndAlso row < Rows Then
            Return New Location(data, Id, column + row * Columns)
        End If
        Return Nothing
    End Function
End Class
