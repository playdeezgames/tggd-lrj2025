Imports TGGDLRJ2025.Data

Friend Class Location
    Implements ILocation

    Private ReadOnly data As WorldData
    Public ReadOnly Property LocationId As Integer Implements ILocation.LocationId
    Private ReadOnly Property LocationData As LocationData
        Get
            Return data.Locations(locationId)
        End Get
    End Property

    Public Sub New(
                  data As WorldData,
                  locationId As Integer)
        Me.data = data
        Me.locationId = locationId
    End Sub

    Public Property LocationType As String Implements ILocation.LocationType
        Get
            Return LocationData.LocationType
        End Get
        Set(value As String)
            If value <> LocationData.LocationType Then
                LocationData.LocationType = value
                value.ToLocationTypeDescriptor.Initialize(Me)
            End If
        End Set
    End Property

    Public ReadOnly Property Map As IMap Implements ILocation.Map
        Get
            Return New Map(data, LocationData.MapId)
        End Get
    End Property

    Public ReadOnly Property World As IWorld Implements ILocation.World
        Get
            Return New World(data)
        End Get
    End Property
End Class
