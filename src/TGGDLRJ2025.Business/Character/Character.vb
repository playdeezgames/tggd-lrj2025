Imports TGGDLRJ2025.Data

Public Class Character
    Inherits InventoriedEntity
    Implements ICharacter
    Private ReadOnly Property CharacterData As CharacterData
        Get
            Return data.Characters(CharacterId)
        End Get
    End Property
    Sub New(data As WorldData, playSfx As Action(Of String), characterId As Integer)
        MyBase.New(data, playSfx)
        Me.CharacterId = characterId
    End Sub

    Public Sub AttemptMove(directionType As String) Implements ICharacter.AttemptMove
        Dim directionDescriptor = directionType.ToDirectionTypeDescriptor
        Dim location = Me.Location
        Dim nextColumn = location.Column + directionDescriptor.DeltaX
        Dim nextRow = location.Row + directionDescriptor.DeltaY
        Dim nextLocation = location.Map.GetLocation(nextColumn, nextRow)
        If nextLocation IsNot Nothing Then
            If nextLocation.HasCharacter Then
                Interact(nextLocation.Character, False)
            ElseIf nextLocation.CanEnter(Me) Then
                HandleThreats(location)
                nextLocation.Character = Me
                CharacterType.ToCharacterTypeDescriptor.OnMove(Me)
            Else
                HandleThreats(location)
                nextLocation.Bump(Me)
                CharacterType.ToCharacterTypeDescriptor.OnMove(Me)
            End If
        End If
    End Sub

    Private Sub HandleThreats(location As ILocation)
        If location.Threatens(Me) Then
            For Each directionType In DirectionTypes.All
                Dim neighbor = location.GetNeighbor(directionType)
                If neighbor?.HasCharacter Then
                    neighbor.Character.Interact(Me, True)
                    If IsDead Then
                        Return
                    End If
                End If
            Next
        End If
    End Sub

    Public Sub AddMessage(sfx As String, lines As IEnumerable(Of (Mood As String, Text As String))) Implements ICharacter.AddMessage
        If IsAvatar Then
            World.AddMessage(sfx, lines)
        End If
    End Sub

    Public Sub UseItem(item As IItem) Implements ICharacter.UseItem
        Dim descriptor = item.ItemType.ToItemTypeDescriptor
        descriptor.OnUse(item, Me)
    End Sub

    Public Sub Interact(otherCharacter As ICharacter, isCounter As Boolean) Implements ICharacter.Interact
        CharacterType.ToCharacterTypeDescriptor.OnInteract(Me, otherCharacter, isCounter)
    End Sub

    Public ReadOnly Property CharacterType As String Implements ICharacter.CharacterType
        Get
            Return CharacterData.CharacterType
        End Get
    End Property

    Public ReadOnly Property CharacterId As Integer Implements ICharacter.CharacterId

    Public ReadOnly Property Location As ILocation Implements ICharacter.Location
        Get
            Return New Location(data, playSfx, CharacterData.LocationId)
        End Get
    End Property

    Public ReadOnly Property Map As IMap Implements ICharacter.Map
        Get
            Return Location.Map
        End Get
    End Property

    Public ReadOnly Property World As IWorld Implements ICharacter.World
        Get
            Return New World(data, playSfx)
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

    Public Overrides ReadOnly Property InventoriedEntityData As InventoriedEntityData
        Get
            Return CharacterData
        End Get
    End Property

    Public ReadOnly Property Name As String Implements ICharacter.Name
        Get
            Return CharacterType.ToCharacterTypeDescriptor.Name
        End Get
    End Property
End Class
