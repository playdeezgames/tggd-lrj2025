Imports TGGDLRJ2025.Data

Friend Class Location
    Implements ILocation

    Private ReadOnly data As WorldData
    Private ReadOnly mapId As Integer
    Private ReadOnly locationIndex As Integer
    Private ReadOnly Property LocationData As LocationData
        Get
            Return data.Maps(mapId).Locations(locationIndex)
        End Get
    End Property

    Public Sub New(
                  data As WorldData,
                  mapId As Integer,
                  locationIndex As Integer)
        Me.data = data
        Me.mapId = mapId
        Me.locationIndex = locationIndex
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
End Class
