Imports TGGDLRJ2025.Data

Public Class Character
    Inherits Entity
    Implements ICharacter
    Private ReadOnly Property CharacterData As CharacterData
        Get
            Return data.Characters(CharacterId)
        End Get
    End Property
    Sub New(data As WorldData, characterId As Integer)
        MyBase.New(data)
        Me.CharacterId = characterId
    End Sub

    Public Sub AttemptMove(directionType As String) Implements ICharacter.AttemptMove
        Dim directionDescriptor = directionType.ToDirectionTypeDescriptor
        Dim location = Me.Location
        Dim nextColumn = location.Column + directionDescriptor.DeltaX
        Dim nextRow = location.Row + directionDescriptor.DeltaY
        Dim nextLocation = location.Map.GetLocation(nextColumn, nextRow)
        If nextLocation IsNot Nothing Then
            If nextLocation.CanEnter(Me) Then
                nextLocation.Character = Me
                CharacterType.ToCharacterTypeDescriptor.OnMove(Me)
            Else
                nextLocation.Bump(Me)
            End If
        End If
    End Sub

    Public Sub AddMessage(lines As IEnumerable(Of (Mood As String, Text As String))) Implements ICharacter.AddMessage
        If IsAvatar Then
            World.AddMessage(lines)
        End If
    End Sub

    Public ReadOnly Property CharacterType As String Implements ICharacter.CharacterType
        Get
            Return CharacterData.CharacterType
        End Get
    End Property

    Public ReadOnly Property CharacterId As Integer Implements ICharacter.CharacterId

    Public ReadOnly Property Location As ILocation Implements ICharacter.Location
        Get
            Return New Location(data, CharacterData.LocationId)
        End Get
    End Property

    Public ReadOnly Property Map As IMap Implements ICharacter.Map
        Get
            Return Location.Map
        End Get
    End Property

    Public ReadOnly Property World As IWorld Implements ICharacter.World
        Get
            Return New World(data)
        End Get
    End Property

    Protected Overrides ReadOnly Property EntityData As EntityData
        Get
            Return CharacterData
        End Get
    End Property

    Public ReadOnly Property IsAvatar As Boolean Implements ICharacter.IsAvatar
        Get
            Return data.AvatarId.HasValue AndAlso data.AvatarId.Value = CharacterId
        End Get
    End Property

    Public ReadOnly Property IsDead As Boolean Implements ICharacter.IsDead
        Get
            Return GetStatistic(StatisticType.Health).Value = GetStatisticMinimum(StatisticType.Health)
        End Get
    End Property
End Class
