Imports TGGDLRJ2025.Data

Public Class Map
    Inherits Entity
    Implements IMap
    Private ReadOnly Property MapData As MapData
        Get
            Return data.Maps(MapId)
        End Get
    End Property
    Sub New(data As WorldData, id As Integer)
        MyBase.New(data)
        Me.MapId = id
    End Sub
    Public ReadOnly Property MapId As Integer Implements IMap.MapId

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

    Public ReadOnly Property World As IWorld Implements IMap.World
        Get
            Return New World(data)
        End Get
    End Property

    Public ReadOnly Property Locations As IEnumerable(Of ILocation) Implements IMap.Locations
        Get
            Return MapData.Locations.Where(Function(x) x.HasValue).Select(Function(x) New Location(data, x.Value))
        End Get
    End Property

    Public ReadOnly Property MapType As String Implements IMap.MapType
        Get
            Return MapData.MapType
        End Get
    End Property

    Protected Overrides ReadOnly Property EntityData As EntityData
        Get
            Return MapData
        End Get
    End Property

    Public Function GetLocation(column As Integer, row As Integer) As ILocation Implements IMap.GetLocation
        If column >= 0 AndAlso column < Columns AndAlso row >= 0 AndAlso row < Rows Then
            Dim locationId = MapData.Locations(column + row * Columns)
            Return If(locationId.HasValue, New Location(data, locationId.Value), Nothing)
        End If
        Return Nothing
    End Function
End Class
