Friend Class LockedDoorLocationTypeDescriptor
    Inherits LocationTypeDescriptor
    Private ReadOnly nextLocationType As String
    Private ReadOnly keyItemType As String

    Public Sub New(
                  locationType As String,
                  isSolid As Boolean,
                  nextLocationType As String,
                  keyItemType As String)
        MyBase.New(locationType, isSolid)
        Me.nextLocationType = nextLocationType
        Me.keyItemType = keyItemType
    End Sub

    Friend Overrides Sub Initialize(location As ILocation)
    End Sub

    Friend Overrides Sub Bump(location As ILocation, character As ICharacter)
        If character.HasItemType(keyItemType) Then
            Dim item = character.GetItemOfType(keyItemType)
            character.RemoveItem(item)
            location.LocationType = nextLocationType
            character.World.PlaySfx(WooHoo)
        Else
            character.World.PlaySfx(Shucks)
        End If
    End Sub

    Friend Overrides Function CanEnter(location As ILocation, character As ICharacter) As Boolean
        Return False
    End Function
End Class
