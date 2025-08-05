Imports TGGDLRJ2025.Data

Friend Class Location
    Inherits Entity
    Implements ILocation

    Public ReadOnly Property LocationId As Integer Implements ILocation.LocationId
    Private ReadOnly Property LocationData As LocationData
        Get
            Return data.Locations(locationId)
        End Get
    End Property

    Public Sub New(
                  data As WorldData,
                  locationId As Integer)
        MyBase.New(data)
        Me.locationId = locationId
    End Sub

    Public Function CanEnter(character As Character) As Boolean Implements ILocation.CanEnter
        If Me.Character IsNot Nothing Then
            Return False
        End If
        Return LocationType.ToLocationTypeDescriptor.CanEnter(Me, character)
    End Function

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

    Public Property Character As ICharacter Implements ILocation.Character
        Get
            Dim characterId = LocationData.CharacterId
            Return If(characterId.HasValue, New Character(data, characterId.Value), Nothing)
        End Get
        Set(value As ICharacter)
            Dim characterId = value.CharacterId
            Dim characterData = data.Characters(characterId)
            Dim oldLocationData = data.Locations(characterData.LocationId)
            oldLocationData.CharacterId = Nothing
            LocationData.CharacterId = characterId
            characterData.LocationId = LocationId
        End Set
    End Property

    Public ReadOnly Property Column As Integer Implements ILocation.Column
        Get
            Return LocationData.Column
        End Get
    End Property

    Public ReadOnly Property Row As Integer Implements ILocation.Row
        Get
            Return LocationData.Row
        End Get
    End Property
End Class
