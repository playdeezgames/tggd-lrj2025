Friend MustInherit Class LocationTypeDescriptor
    ReadOnly Property LocationType As String
    ReadOnly Property IsSolid As Boolean
    Sub New(locationType As String, isSolid As Boolean)
        Me.LocationType = locationType
        Me.IsSolid = isSolid
    End Sub
    Friend MustOverride Sub Initialize(location As ILocation)
    Friend MustOverride Function CanEnter(location As ILocation, character As ICharacter) As Boolean
    Friend MustOverride Sub Bump(location As ILocation, character As ICharacter)
End Class
