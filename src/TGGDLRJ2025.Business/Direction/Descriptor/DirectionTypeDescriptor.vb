Imports System.ComponentModel.DataAnnotations.Schema

Friend MustInherit Class DirectionTypeDescriptor
    Friend ReadOnly Property DirectionType As String
    Friend ReadOnly Property DeltaX As Integer
    Friend ReadOnly Property DeltaY As Integer
    Friend ReadOnly Property OppositeDirectionType As String

    Public Sub New(directionType As String, deltaX As Integer, deltaY As Integer, oppositeDirectionType As String)
        Me.DirectionType = directionType
        Me.DeltaX = deltaX
        Me.DeltaY = deltaY
        Me.OppositeDirectionType = oppositeDirectionType
    End Sub
    MustOverride Function GetDoorFromLocation(map As IMap) As (Column As Integer, Row As Integer)
    MustOverride Function GetDoorToLocation(map As IMap) As (Column As Integer, Row As Integer)
End Class
