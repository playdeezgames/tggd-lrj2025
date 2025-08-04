Friend MustInherit Class LocationTypeDescriptor
    ReadOnly Property LocationType As String
    Sub New(locationType As String)
        Me.LocationType = locationType
    End Sub
    Friend MustOverride Sub Initialize(location As ILocation)
    Friend MustOverride Function CanEnter(location As ILocation, character As ICharacter) As Boolean
End Class
