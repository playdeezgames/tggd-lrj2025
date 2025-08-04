Imports TGGDLRJ2025.Data

Public Class Character
    Implements ICharacter
    Private data As WorldData
    Private ReadOnly Property CharacterData As CharacterData
        Get
            Return data.Characters(CharacterId)
        End Get
    End Property
    Sub New(data As WorldData, characterId As Integer)
        Me.data = data
        Me.CharacterId = characterId
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
End Class
