Friend Class DirectionTypeDescriptor
    Friend ReadOnly Property DirectionType As String
    Friend ReadOnly Property DeltaX As Integer
    Friend ReadOnly Property DeltaY As Integer

    Public Sub New(directionType As String, deltaX As Integer, deltaY As Integer)
        Me.DirectionType = directionType
        Me.DeltaX = deltaX
        Me.DeltaY = deltaY
    End Sub
End Class
